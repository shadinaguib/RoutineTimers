import ActivityKit
import Foundation

struct RoutineLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let currentTitle: String
        let nextTitle: String?
        let stepIndex: Int
        let stepCount: Int
        let secondsRemaining: Int
        let stepEndDate: Date?
        let isRunning: Bool
    }

    let routineName: String
}
