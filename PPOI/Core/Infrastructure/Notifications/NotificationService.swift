import UserNotifications

final class NotificationService {
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleDailyNotification(hour: Int, enabled: Bool) async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        guard enabled else { return }

        // 曜日ごとに異なるメッセージを配信（weekday: 1=日, 2=月, ... 7=土）
        for weekday in 1...7 {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0
            dateComponents.weekday = weekday
            dateComponents.timeZone = TimeZone(identifier: "Asia/Tokyo")

            let message = Self.dailyMessages[weekday - 1]
            let content = UNMutableNotificationContent()
            content.title = message.title
            content.body = message.body
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "daily-quote-\(weekday)",
                content: content,
                trigger: trigger
            )

            await withCheckedContinuation { continuation in
                center.add(request) { _ in
                    continuation.resume()
                }
            }
        }
    }

    private static let dailyMessages: [(title: String, body: String)] = [
        ("今日の「っぽい格言」", "日曜の朝にぴったりの一句。"),
        ("今日の「っぽい格言」", "今日だけ読める一句が届きました。"),
        ("今日の「っぽい格言」", "今日のは…ちょっと哲学的かも。"),
        ("今日の「っぽい格言」", "今日の格言、刺さるかもしれません。"),
        ("今日の「っぽい格言」", "今日のはネタ寄り？真面目？開いてみて。"),
        ("今日の「っぽい格言」", "誰かにシェアしたくなる一句かも。"),
        ("今日の「っぽい格言」", "週末の一句。AIの言葉に耳を傾けよう。"),
    ]
}
