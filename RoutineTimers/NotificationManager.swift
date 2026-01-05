import Foundation
import UserNotifications

enum NotificationManager {
    static let morningCategoryId = "morning_routine"
    static let startActionId = "start_morning_routine"
    static let autoStartKey = "RoutineTimers.autoStartMorningRoutine"

    static func configure() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            registerCategories(center: center)
            scheduleMorningNotification()
        }
    }

    static func registerCategories(center: UNUserNotificationCenter) {
        let startAction = UNNotificationAction(
            identifier: startActionId,
            title: "Start Morning Routine",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: morningCategoryId,
            actions: [startAction],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])
    }

    static func scheduleMorningNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Morning Routine"
        content.body = morningRoutineSummary()
        content.sound = .default
        content.categoryIdentifier = morningCategoryId

        var dateComponents = DateComponents()
        dateComponents.hour = 7
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "morning_routine_daily",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    static func morningRoutineSummary() -> String {
        let routine = RoutineStore.defaultRoutines().first { $0.name == "Morning Launch" }
        let steps = routine?.steps ?? []
        let parts = steps.map { "\($0.title) (\($0.minutes)m)" }
        return parts.joined(separator: " • ")
    }
}
