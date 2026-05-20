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

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0
        dateComponents.timeZone = TimeZone(identifier: "Asia/Tokyo")

        let content = UNMutableNotificationContent()
        content.title = "今日の「っぽい格言」"
        content.body = "今日だけ読める一句が届きました。"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily-quote",
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
