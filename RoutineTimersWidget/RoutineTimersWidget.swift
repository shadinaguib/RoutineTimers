import ActivityKit
import SwiftUI
import WidgetKit

@main
struct RoutineTimersWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RoutineLiveActivityAttributes.self) { context in
            RoutineLiveActivityView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.85))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("Routine")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(stepCountText(context))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.currentTitle)
                        .font(.headline)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    timerView(context)
                }
            } compactLeading: {
                Text("RT")
            } compactTrailing: {
                compactTimer(context)
            } minimal: {
                Text("RT")
            }
        }
    }

    private func stepCountText(_ context: ActivityViewContext<RoutineLiveActivityAttributes>) -> String {
        let step = min(context.state.stepIndex + 1, context.state.stepCount)
        return "Step \(step)/\(context.state.stepCount)"
    }

    @ViewBuilder
    private func timerView(_ context: ActivityViewContext<RoutineLiveActivityAttributes>) -> some View {
        if context.state.isRunning, let endDate = context.state.stepEndDate {
            Text(timerInterval: Date()...endDate, countsDown: true)
                .font(.system(size: 48, weight: .heavy, design: .rounded))
                .monospacedDigit()
        } else {
            Text(formatTime(context.state.secondsRemaining))
                .font(.system(size: 48, weight: .heavy, design: .rounded))
                .monospacedDigit()
        }
    }

    @ViewBuilder
    private func compactTimer(_ context: ActivityViewContext<RoutineLiveActivityAttributes>) -> some View {
        if context.state.isRunning, let endDate = context.state.stepEndDate {
            Text(timerInterval: Date()...endDate, countsDown: true)
                .font(.caption2)
                .monospacedDigit()
        } else {
            Text(formatTime(context.state.secondsRemaining))
                .font(.caption2)
                .monospacedDigit()
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

struct RoutineLiveActivityView: View {
    let context: ActivityViewContext<RoutineLiveActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(context.attributes.routineName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(1)

            Text(context.state.currentTitle)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.tail)

            timerSection

            Text(nextLine)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .foregroundStyle(.white)
    }

    private var stepCountText: String {
        let step = min(context.state.stepIndex + 1, context.state.stepCount)
        return "Step \(step) of \(context.state.stepCount)"
    }

    @ViewBuilder
    private var timerSection: some View {
        if context.state.isRunning, let endDate = context.state.stepEndDate {
            Text(timerInterval: Date()...endDate, countsDown: true)
                .font(.system(size: 52, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .leading)
                .minimumScaleFactor(0.7)
        } else {
            Text(formatTime(context.state.secondsRemaining))
                .font(.system(size: 52, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .leading)
                .minimumScaleFactor(0.7)
        }
    }

    private var nextLine: String {
        if let nextTitle = context.state.nextTitle {
            return "Next: \(nextTitle)"
        }
        return "Last step"
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview("Live Activity", as: .content, using: RoutineLiveActivityAttributes(routineName: "Morning Launch")) {
    RoutineTimersWidget()
} contentStates: {
    RoutineLiveActivityAttributes.ContentState(
        currentTitle: "Feet on floor",
        nextTitle: "Take creatine pills",
        stepIndex: 0,
        stepCount: 5,
        secondsRemaining: 60,
        stepEndDate: Date().addingTimeInterval(60),
        isRunning: true
    )
}
