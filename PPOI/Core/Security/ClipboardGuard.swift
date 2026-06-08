import UIKit

/// B6: Auto-clear clipboard after sensitive content is shared.
/// Prevents quote text from persisting in the system pasteboard.
enum ClipboardGuard {
    private static let clearDelay: TimeInterval = 60

    /// Schedule pasteboard clearing after a delay.
    /// Call this after share activities complete.
    static func scheduleClipboardClear() {
        let changeCountAtShare = UIPasteboard.general.changeCount
        DispatchQueue.main.asyncAfter(deadline: .now() + clearDelay) {
            let pasteboard = UIPasteboard.general
            // Only clear if the clipboard hasn't been changed since our share
            guard pasteboard.changeCount == changeCountAtShare else { return }
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
