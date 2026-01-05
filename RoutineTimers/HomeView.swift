import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: RoutineStore
    @State private var autoStartRoutine: Routine?
    private let cardCornerRadius: CGFloat = 16

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Routine Timers")
                    .font(.largeTitle).bold()

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
                                Label("Start", systemImage: "play.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                    .frame(minWidth: 84)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.white)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
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

    private func routineButton(_ routine: Routine) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(routine.name)
                .font(.title2).bold()
                .lineLimit(1)
            HStack(spacing: 12) {
                Label("\(routine.steps.count) steps", systemImage: "list.number")
                Label("\(routine.totalMinutes) min", systemImage: "clock")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HomeView().environmentObject(RoutineStore())
}
