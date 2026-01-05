import Foundation
import UserNotifications

enum NotificationManager {
    static let morningCategoryId = "morning_routine"
    static let startActionId = "start_morning_routine"
    static let autoStartKey = "RoutineTimers.autoStartMorningRoutine"
    static let routineStepNotificationPrefix = "routine_step_"

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

    static func scheduleRoutineStepNotifications(
        routineName: String,
        steps: [Step],
        startingAt stepIndex: Int,
        secondsRemainingInStep: Int
    ) {
        cancelRoutineStepNotifications()
        guard stepIndex < steps.count else { return }

        var cumulativeSeconds = max(1, secondsRemainingInStep)
        let center = UNUserNotificationCenter.current()

        for idx in stepIndex..<steps.count {
            let step = steps[idx]
            let title = routineName
            let nextTitle = steps.indices.contains(idx + 1) ? steps[idx + 1].title : nil
            let body = nextTitle != nil
                ? "Step complete: \(step.title). Next: \(nextTitle!)"
                : "Routine complete"

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: TimeInterval(cumulativeSeconds),
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "\(routineStepNotificationPrefix)\(idx)",
                content: content,
                trigger: trigger
            )
            center.add(request)

            if steps.indices.contains(idx + 1) {
                cumulativeSeconds += steps[idx + 1].minutes * 60
            }
        }
    }

    static func cancelRoutineStepNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(routineStepNotificationPrefix) }
            if !ids.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: ids)
            }
        }
    }

    static func morningRoutineSummary() -> String {
        let routine = RoutineStore.defaultRoutines().first { $0.name == "Morning Launch" }
        let steps = routine?.steps ?? []
        let parts = steps.map { "\($0.title) (\($0.minutes)m)" }
        return parts.joined(separator: " • ")
    }
}
