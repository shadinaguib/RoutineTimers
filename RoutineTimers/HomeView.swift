import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: RoutineStore
    @State private var autoStartRoutine: Routine?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Routine Timers")
                    .font(.largeTitle).bold()

                statsRow

                VStack(spacing: 12) {
                    ForEach(store.routines) { routine in
                        HStack(spacing: 12) {
                            NavigationLink(value: routine) {
                                routineButton(routine)
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                RoutinePlayerView(routine: routine)
                                    .onAppear {
                                        if store.activeRoutine?.id != routine.id {
                                            store.startRoutine(routine)
                                        }
                                    }
                            } label: {
                                Text("Start")
                                    .font(.headline)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 14)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }

                NavigationLink {
                    HistoryView()
                } label: {
                    Text("History")
                        .font(.headline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Capsule())
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding()
            .navigationDestination(for: Routine.self) { routine in
                RoutineDetailView(routine: routine)
            }
            .navigationDestination(item: $autoStartRoutine) { routine in
                RoutinePlayerView(routine: routine)
                    .onAppear {
                        if store.activeRoutine?.id != routine.id {
                            store.startRoutine(routine)
                        }
                    }
            }
        }
        .onAppear {
            let key = NotificationManager.autoStartKey
            guard UserDefaults.standard.bool(forKey: key) else { return }
            UserDefaults.standard.set(false, forKey: key)
            if let routine = store.routines.first(where: { $0.name == "Morning Launch" }) {
                autoStartRoutine = routine
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 20) {
            statBox(title: "Today", value: "\(store.todayCount)")
            statBox(title: "Streak", value: "\(store.streakCount)")
        }
    }

    private func statBox(title: String, value: String) -> some View {
        VStack {
            Text(title).font(.subheadline).foregroundStyle(.secondary)
            Text(value).font(.title2).monospacedDigit().bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func routineButton(_ routine: Routine) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(routine.name)
                .font(.title2).bold()
            HStack(spacing: 12) {
                Label("\(routine.steps.count) steps", systemImage: "list.number")
                Label("\(routine.totalMinutes) min", systemImage: "clock")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    HomeView().environmentObject(RoutineStore())
}
