import StoreKit
import UIKit

/// 条件を満たしたユーザーに App Store レビューを促す
@MainActor
enum ReviewPromptManager {
    /// 3日連続閲覧 かつ シェア1回以上 → レビュー依頼（60日に1回まで）
    static func requestIfEligible(preferences: UserPreferencesStore, streak: StreakTracker) {
        guard streak.currentStreak >= 3,
              preferences.totalShareCount >= 1
        else { return }

        if let last = preferences.lastReviewPromptDate,
           let lastDate = DateFormatter.jstDate.date(from: last)
        {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
            let days = calendar.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            if days < 60 { return }
        }

        preferences.lastReviewPromptDate = DateFormatter.jstDate.string(from: Date())

        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0 is UIWindowScene }) as? UIWindowScene
        else { return }

        SKStoreReviewController.requestReview(in: scene)
    }
}
