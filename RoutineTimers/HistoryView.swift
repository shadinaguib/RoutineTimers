import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: RoutineStore

    var body: some View {
        List {
            if store.history.isEmpty {
                Text("No completions yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(store.history) { run in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(run.routineName)
                            .font(.headline)
                        Text(run.completedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("History")
    }
}

#Preview {
    HistoryView().environmentObject(RoutineStore())
}
