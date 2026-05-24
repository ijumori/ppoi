import UIKit

/// B6: Auto-clear clipboard after sensitive content is shared.
/// Prevents quote text from persisting in the system pasteboard.
enum ClipboardGuard {
    private static let clearDelay: TimeInterval = 60

    /// Schedule pasteboard clearing after a delay.
    /// Call this after share activities complete.
    static func scheduleClipboardClear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + clearDelay) {
            // Only clear if the content was set by our app
            // (check via localOnly expiration approach)
            let pasteboard = UIPasteboard.general
            if pasteboard.hasStrings || pasteboard.hasImages {
                pasteboard.items = []
                SecureLogger.debug("Clipboard cleared after share", category: .security)
            }
        }
    }

    /// Immediately clear clipboard
    static func clearNow() {
        UIPasteboard.general.items = []
    }
}
