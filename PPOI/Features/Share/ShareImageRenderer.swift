import SwiftUI
import UIKit

@MainActor
enum ShareImageRenderer {
    static func render(
        quote: Quote,
        reflection: String,
        theme: AppTheme,
        fontVariant: FontVariant
    ) -> UIImage? {
        let view = ShareCardExportView(
            quote: quote,
            reflection: reflection,
            theme: theme,
            fontVariant: fontVariant
        )

        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        return renderer.uiImage
    }
}

/// UIActivityViewController を表示（SwiftUI の sheet 二重表示を避ける）
@MainActor
enum ShareActivityPresenter {
    static func present(
        items: [Any],
        onComplete: ((Bool) -> Void)? = nil
    ) {
        guard let presenter = ViewControllerFinder.topMost(),
              presenter.presentedViewController == nil else { return }

        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        controller.completionWithItemsHandler = { activityType, completed, _, _ in
            // 𝕏 等へ送った場合でも completed が false になることがある
            let didShare = completed || activityType != nil
            if didShare {
                ClipboardGuard.scheduleClipboardClear()
            }
            onComplete?(didShare)
        }

        if let popover = controller.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(
                x: presenter.view.bounds.midX,
                y: presenter.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        presenter.present(controller, animated: true)
    }
}

private enum ViewControllerFinder {
    static func topMost() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostPresented()
    }
}

private extension UIViewController {
    func topMostPresented() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostPresented()
        }
        if let navigation = self as? UINavigationController,
           let visible = navigation.visibleViewController {
            return visible.topMostPresented()
        }
        if let tab = self as? UITabBarController,
           let selected = tab.selectedViewController {
            return selected.topMostPresented()
        }
        return self
    }
}

enum ShareTextBuilder {
    static func build(reflection: String) -> String {
        let trimmed = InputSanitizer.sanitizeReflection(reflection)
        if trimmed.isEmpty {
            return "明日には消える一句\n#っぽい格言"
        }
        return "私の考察：\(trimmed)\n\n明日には消える一句\n#っぽい格言"
    }
}
