import SwiftUI

struct RoutinePlayerView: View {
    @EnvironmentObject private var store: RoutineStore
    @Environment(\.dismiss) private var dismiss
    let routine: Routine

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(routine.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            if let step = currentStep {
                Text("Step \(store.currentStepIndex + 1) of \(routine.steps.count)")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(step.title)
                    .font(.title).bold()

                Text(formatTime(store.secondsRemaining))
                    .font(.system(size: 96, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .padding(.vertical, 18)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                if let next = nextStep {
                    VStack(spacing: 4) {
                        Text("Next")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(next.title)
                            .font(.headline)
                    }
                } else {
                    Text("Last step")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 14) {
                Button(role: .destructive) {
                    store.skipStep()
                } label: {
                    Label("Next", systemImage: "forward.fill")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button(action: {
                    store.isRunning ? store.pause() : store.resume()
                }) {
                    Label(store.isRunning ? "Pause" : "Resume", systemImage: store.isRunning ? "pause.fill" : "play.fill")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            if currentStep != nil {
                Button(role: .cancel) {
                    store.quitRoutine()
                } label: {
                    Text("Quit Routine")
                        .foregroundStyle(.red)
                }
            } else {
                VStack(spacing: 12) {
                    Text("Routine complete")
                        .font(.headline)
                    Button("Close") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            Spacer()
        }
        .padding()
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Text("") } }
        .onDisappear {
            // If user swipes back while running, treat as quit per MVP (no completion recorded)
            if store.activeRoutine != nil { store.quitRoutine() }
        }
    }

    private var currentStep: Step? {
        guard let active = store.activeRoutine, active.id == routine.id else { return nil }
        guard store.currentStepIndex < active.steps.count else { return nil }
        return active.steps[store.currentStepIndex]
    }

    private var nextStep: Step? {
        guard let active = store.activeRoutine, active.id == routine.id else { return nil }
        let nextIndex = store.currentStepIndex + 1
        guard nextIndex < active.steps.count else { return nil }
        return active.steps[nextIndex]
    }
}

#Preview {
    NavigationStack { RoutinePlayerView(routine: RoutineStore.defaultRoutines()[0]) }
        .environmentObject(RoutineStore())
}
