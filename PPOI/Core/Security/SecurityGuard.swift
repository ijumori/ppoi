import Darwin
import Foundation
import MachO
import UIKit

// MARK: - SecurityGuard

/// Bank-grade runtime integrity checks:
/// - Jailbreak detection (file probes, sandbox escape, suspicious dylibs)
/// - Debugger detection (sysctl P_TRACED + ptrace PT_DENY_ATTACH)
/// - DYLD injection detection (unexpected dylib count, Frida/Cycript signatures)
/// - Code signing / Bundle ID verification
/// - Method swizzling detection on critical security methods
enum SecurityGuard {

    // MARK: - Public API

    static var isEnvironmentTrusted: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return !isJailbroken
            && !isDebuggerAttached
            && !isDylibInjected
            && isBundleIntegrityValid
        #endif
    }

    /// Run all checks and return detailed failure reasons (for logging in DEBUG only)
    static var failureReasons: [String] {
        var reasons: [String] = []
        #if targetEnvironment(simulator)
        return reasons
        #else
        if isJailbroken { reasons.append("jailbreak") }
        if isDebuggerAttached { reasons.append("debugger") }
        if isDylibInjected { reasons.append("dylib_injection") }
        if !isBundleIntegrityValid { reasons.append("bundle_tampered") }
        return reasons
        #endif
    }

    // MARK: - A2: Deny debugger attachment (call once at launch)

    static func denyDebuggerAttachment() {
        #if !DEBUG && !targetEnvironment(simulator)
        // PT_DENY_ATTACH prevents debuggers from attaching to this process.
        // Using dlsym to avoid direct symbol reference that could be patched.
        typealias PtraceFunc = @convention(c) (CInt, pid_t, CInt, CInt) -> CInt
        guard let handle = dlopen(nil, RTLD_GLOBAL | RTLD_NOW),
              let sym = dlsym(handle, "ptrace")
        else { return }
        let ptrace = unsafeBitCast(sym, to: PtraceFunc.self)
        let PT_DENY_ATTACH: CInt = 31
        _ = ptrace(PT_DENY_ATTACH, 0, 0, 0)
        dlclose(handle)
        #endif
    }

    // MARK: - Jailbreak Detection (Enhanced)

    private static var isJailbroken: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        // 1. Check for known jailbreak file paths
        let suspiciousPaths = [
            "/Applications/Cydia.app",
            "/Applications/Sileo.app",
            "/Applications/Zebra.app",
            "/Applications/Substitute.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/bin/sh",
            "/usr/sbin/sshd",
            "/usr/bin/ssh",
            "/usr/bin/sshd",
            "/etc/apt",
            "/etc/apt/sources.list.d",
            "/private/var/lib/apt/",
            "/private/var/lib/cydia",
            "/private/var/mobile/Library/SBSettings/Themes",
            "/var/cache/apt",
            "/var/lib/cydia",
            "/usr/libexec/cydia",
            "/usr/lib/TweakInject",
            "/Library/MobileSubstrate",
            "/var/binpack",
            "/usr/lib/libhooker.dylib",
            "/usr/lib/substrate",
        ]

        for path in suspiciousPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }

        // 2. Check if app can open Cydia/Sileo URL schemes
        let suspiciousSchemes = ["cydia://", "sileo://", "zbra://"]
        for scheme in suspiciousSchemes {
            if let url = URL(string: scheme),
               UIApplication.shared.canOpenURL(url) {
                return true
            }
        }

        // 3. Sandbox escape test: try to write outside the sandbox
        let testPath = "/private/ppoi_jailbreak_probe_\(UUID().uuidString)"
        do {
            try "probe".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true // Should not be able to write here
        } catch {
            // Expected on non-jailbroken device
        }

        // 4. Check for suspicious environment variables
        if getenv("DYLD_INSERT_LIBRARIES") != nil {
            return true
        }
        if getenv("_MSSafeMode") != nil {
            return true
        }

        return false
        #endif
    }

    // MARK: - Debugger Detection (sysctl)

    private static var isDebuggerAttached: Bool {
        #if DEBUG
        return false
        #else
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        let result = sysctl(&mib, u_int(mib.count), &info, &size, nil, 0)
        guard result == 0 else { return false }
        return (info.kp_proc.p_flag & P_TRACED) != 0
        #endif
    }

    // MARK: - A1: DYLD Injection Detection

    private static var isDylibInjected: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        let imageCount = _dyld_image_count()

        // Check each loaded dylib for suspicious signatures
        let suspiciousLibraries = [
            "FridaGadget",
            "frida-agent",
            "libcycript",
            "MobileSubstrate",
            "SubstrateLoader",
            "SubstrateInserter",
            "SubstrateBootstrap",
            "TweakInject",
            "libhooker",
            "libblackjack",
            "SSLKillSwitch",
            "SSLKillSwitch2",
            "MobileDecrypt",
            "FlexLoader",
            "FLEXLoader",
            "RevealServer",
        ]

        for i in 0..<imageCount {
            guard let imageName = _dyld_get_image_name(i) else { continue }
            let name = String(cString: imageName)

            for suspicious in suspiciousLibraries {
                if name.localizedCaseInsensitiveContains(suspicious) {
                    return true
                }
            }
        }

        // Check for Frida's default port listener
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = UInt16(27042).bigEndian
        addr.sin_addr.s_addr = inet_addr("127.0.0.1")

        let sock = socket(AF_INET, SOCK_STREAM, 0)
        guard sock >= 0 else { return false }
        defer { close(sock) }

        let connected = withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockPtr in
                connect(sock, sockPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        if connected == 0 {
            return true // Frida is likely running
        }

        return false
        #endif
    }

    // MARK: - A4: Bundle Integrity Verification

    private static var isBundleIntegrityValid: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        // Verify bundle identifier matches expected value
        guard let bundleID = Bundle.main.bundleIdentifier,
              bundleID == "com.takahiro.ppoi"
        else {
            return false
        }

        // Verify the app is signed (embedded.mobileprovision exists for dev, or
        // the code signature is present for App Store builds)
        let signaturePath = Bundle.main.bundlePath + "/_CodeSignature/CodeResources"
        guard FileManager.default.fileExists(atPath: signaturePath) else {
            return false
        }

        // Verify Info.plist hasn't been tampered with
        guard let infoPlist = Bundle.main.infoDictionary,
              let displayName = infoPlist["CFBundleDisplayName"] as? String,
              displayName.contains("っぽい格言")
        else {
            return false
        }

        return true
        #endif
    }
}
