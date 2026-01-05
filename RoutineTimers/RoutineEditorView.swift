import SwiftUI

struct RoutineEditorView: View {
    @EnvironmentObject private var store: RoutineStore
    @Environment(\.dismiss) private var dismiss
    @State private var draft: Routine

    init(routine: Routine) {
        _draft = State(initialValue: routine)
    }

    var body: some View {
        List {
            Section {
                Text(draft.name)
                    .font(.title3)
                    .bold()
                Text("\(draft.steps.count) steps • \(draft.totalMinutes) min")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Steps") {
                ForEach($draft.steps) { $step in
                    StepEditorRow(step: $step)
                }
                .onDelete(perform: deleteSteps)
                .onMove(perform: moveSteps)

                Button {
                    addStep()
                } label: {
                    Label("Add Step", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Edit Routine")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { saveChanges() }
            }
        }
    }

    private func addStep() {
        draft.steps.append(Step(title: "New Step", minutes: 2))
    }

    private func deleteSteps(at offsets: IndexSet) {
        draft.steps.remove(atOffsets: offsets)
    }

    private func moveSteps(from source: IndexSet, to destination: Int) {
        draft.steps.move(fromOffsets: source, toOffset: destination)
    }

    private func saveChanges() {
        store.updateRoutine(draft)
        dismiss()
    }
}

private struct StepEditorRow: View {
    @Binding var step: Step

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Step title", text: $step.title)
            Stepper(value: $step.minutes, in: 1...120) {
                Text("\(step.minutes) min")
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    NavigationStack {
        RoutineEditorView(routine: RoutineStore.defaultRoutines()[0])
            .environmentObject(RoutineStore())
    }
}
