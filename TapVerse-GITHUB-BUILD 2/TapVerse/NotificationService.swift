import Foundation
import UserNotifications

struct NotificationService {
    static func requestPermissionAndSchedule() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            guard granted else { return false }
            await scheduleComebackReminder()
            return true
        } catch {
            return false
        }
    }

    static func disableReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["tapverse.comeback"])
    }

    static func scheduleComebackReminder() async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["tapverse.comeback"])

        let content = UNMutableNotificationContent()
        content.title = "Твоя фабрика накопила монеты"
        content.body = "Забери офлайн-доход и не потеряй ежедневную серию."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60 * 60 * 8, repeats: false)
        let request = UNNotificationRequest(identifier: "tapverse.comeback", content: content, trigger: trigger)
        try? await center.add(request)
    }
}
