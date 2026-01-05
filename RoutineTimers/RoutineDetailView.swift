import SwiftUI

struct RoutineDetailView: View {
    @EnvironmentObject private var store: RoutineStore
    @State private var isPresentingPlayer = false
    let routine: Routine

    private var currentRoutine: Routine {
        store.routines.first(where: { $0.id == routine.id }) ?? routine
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(currentRoutine.name)
                        .font(.title2)
                        .bold()
                    Text("\(currentRoutine.steps.count) steps • \(currentRoutine.totalMinutes) min")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("Steps") {
                ForEach(currentRoutine.steps) { step in
                    HStack {
                        Text(step.title)
                        Spacer()
                        Text("\(step.minutes) min")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Button {
                    guard !currentRoutine.steps.isEmpty else { return }
                    store.startRoutine(currentRoutine)
                    isPresentingPlayer = true
                } label: {
                    Text("Start Routine")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("Routine")
        .navigationDestination(isPresented: $isPresentingPlayer) {
            RoutinePlayerView(routine: currentRoutine)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    RoutineEditorView(routine: currentRoutine)
                } label: {
                    Text("Edit")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RoutineDetailView(routine: RoutineStore.defaultRoutines()[0])
            .environmentObject(RoutineStore())
    }
}
