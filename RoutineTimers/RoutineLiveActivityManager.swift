import ActivityKit
import Foundation

final class RoutineLiveActivityManager {
    private var activity: Activity<RoutineLiveActivityAttributes>?

    func start(routine: Routine, state: RoutineLiveActivityAttributes.ContentState) {
        let attributes = RoutineLiveActivityAttributes(routineName: routine.name)
        let content = ActivityContent(state: state, staleDate: state.stepEndDate)
        do {
            self.activity = try Activity.request(attributes: attributes, content: content, pushType: nil)
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    func update(state: RoutineLiveActivityAttributes.ContentState) {
        guard let currentActivity = activity else { return }
        let content = ActivityContent(state: state, staleDate: state.stepEndDate)
        Task {
            await currentActivity.update(content)
        }
    }

    func end(finalState: RoutineLiveActivityAttributes.ContentState) {
        guard let currentActivity = activity else { return }
        let content = ActivityContent(state: finalState, staleDate: nil)
        Task {
            await currentActivity.end(content, dismissalPolicy: .immediate)
        }
        self.activity = nil
    }
}
