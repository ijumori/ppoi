import CryptoKit
import Foundation
import Security

/// C1: Network security utilities.
///
/// Firebase SDK manages its own gRPC/TLS connections, so direct SSL pinning
/// on Firebase is unnecessary and could break with SDK updates.
/// This module provides a secure URLSession for any future custom API calls
/// with public key pinning support.
enum NetworkSecurity {

    /// Pinned public key hashes (SHA-256, base64-encoded).
    /// Update these when rotating server certificates.
    /// Currently unused as all traffic goes through Firebase SDK,
    /// but ready for custom API endpoints.
    static let pinnedPublicKeyHashes: [String] = []

    /// Create a URLSession with certificate pinning delegate.
    /// Use this for any non-Firebase HTTP requests.
    static func makePinnedSession(
        pinnedHashes: [String] = pinnedPublicKeyHashes,
        configuration: URLSessionConfiguration = .ephemeral
    ) -> URLSession {
        // Ephemeral = no caches, cookies, or credentials written to disk
        configuration.urlCache = nil
        configuration.httpCookieStorage = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv12

        let delegate = PinningDelegate(pinnedHashes: pinnedHashes)
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
}

// MARK: - Certificate Pinning Delegate

final class PinningDelegate: NSObject, URLSessionDelegate {
    private let pinnedHashes: [String]

    init(pinnedHashes: [String]) {
        self.pinnedHashes = pinnedHashes
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust
        else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // If no pins configured, use default validation
        guard !pinnedHashes.isEmpty else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // Evaluate the server trust
        var error: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &error) else {
            SecureLogger.error("TLS trust evaluation failed: \(error?.localizedDescription ?? "unknown")", category: .network)
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Extract and pin public keys
        let certCount = SecTrustGetCertificateCount(serverTrust)
        var matched = false

        for i in 0..<certCount {
            guard let certificate = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
                  i < certificate.count
            else { continue }

            guard let publicKey = SecCertificateCopyKey(certificate[i]),
                  let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data?
            else { continue }

            let hash = SHA256.hash(data: publicKeyData)
            let hashBase64 = Data(hash).base64EncodedString()

            if pinnedHashes.contains(hashBase64) {
                matched = true
                break
            }
        }

        if matched {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            SecureLogger.error("Certificate pinning failed for \(challenge.protectionSpace.host)", category: .network)
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
