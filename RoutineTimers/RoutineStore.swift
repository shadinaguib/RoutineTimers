import Foundation
import Combine

final class RoutineStore: ObservableObject {
    // MARK: - Published State
    @Published private(set) var routines: [Routine] = []
    @Published private(set) var history: [Run] = [] // newest first

    // Active routine state
    @Published var activeRoutine: Routine? = nil
    @Published private(set) var currentStepIndex: Int = 0
    @Published private(set) var secondsRemaining: Int = 0
    @Published private(set) var isRunning: Bool = false

    // Navigation hints
    @Published var isPlaying: Bool = false

    // Timer
    private var timer: Timer?

    // Persistence
    private let historyKey = "RoutineTimers.history"

    init() {
        self.routines = Self.defaultRoutines()
        self.history = loadHistory()
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - Defaults
    static func defaultRoutines() -> [Routine] {
        return [
            Routine(
                name: "Morning Launch",
                steps: [
                    Step(title: "Feet on floor", minutes: 1),
                    Step(title: "Take creatine pills", minutes: 1),
                    Step(title: "Shower, brush teeth, get dressed", minutes: 10),
                    Step(title: "Gym bag", minutes: 3),
                    Step(title: "Leave appartment", minutes: 1)
                ]
            ),
            Routine(
                name: "Work Start",
                steps: [
                    Step(title: "Phone away / Focus mode", minutes: 2),
                    Step(title: "Open the ONE doc", minutes: 2),
                    Step(title: "Ugly outline (no polish)", minutes: 6),
                    Step(title: "Write next micro-step at top", minutes: 2)
                ]
            ),
            Routine(
                name: "Workout Start",
                steps: [
                    Step(title: "Put on workout clothes", minutes: 4),
                    Step(title: "Warm-up", minutes: 4),
                    Step(title: "One set (push/squat/pull)", minutes: 4),
                    Step(title: "Decide: continue or finish", minutes: 2)
                ]
            )
        ]
    }

    // MARK: - Timer / Player Controls
    func startRoutine(_ routine: Routine) {
        activeRoutine = routine
        currentStepIndex = 0
        secondsRemaining = max(0, routine.steps.first?.minutes ?? 0) * 60
        isRunning = true
        isPlaying = true
        startTimer()
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
    }

    func resume() {
        guard activeRoutine != nil else { return }
        isRunning = true
        startTimer()
    }

    func skipStep() {
        guard let routine = activeRoutine else { return }
        advance(from: routine)
    }

    func quitRoutine() {
        timer?.invalidate()
        isRunning = false
        isPlaying = false
        activeRoutine = nil
    }

    // MARK: - Editing
    func updateRoutine(_ routine: Routine) {
        guard let index = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        routines[index] = routine
        if let active = activeRoutine, active.id == routine.id, !isPlaying {
            activeRoutine = routine
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func tick() {
        guard isRunning, let routine = activeRoutine else { return }
        if secondsRemaining > 0 {
            secondsRemaining -= 1
        } else {
            advance(from: routine)
        }
    }

    private func advance(from routine: Routine) {
        // Move to next step or finish
        if currentStepIndex + 1 < routine.steps.count {
            currentStepIndex += 1
            secondsRemaining = routine.steps[currentStepIndex].minutes * 60
        } else {
            // Completed routine
            completeRoutine(named: routine.name)
        }
    }

    private func completeRoutine(named name: String) {
        timer?.invalidate()
        isRunning = false
        isPlaying = false
        let run = Run(routineName: name, completedAt: Date())
        history.insert(run, at: 0)
        saveHistory()
        activeRoutine = nil
    }

    // MARK: - Stats
    var todayCount: Int {
        let cal = Calendar.current
        return history.filter { cal.isDateInToday($0.completedAt) }.count
    }

    var streakCount: Int {
        // Count consecutive days from today backwards with at least one completion
        let cal = Calendar.current
        var dayOffset = 0
        var streak = 0
        while true {
            guard let day = cal.date(byAdding: .day, value: -dayOffset, to: Date()) else { break }
            let hasRun = history.contains { cal.isDate($0.completedAt, inSameDayAs: day) }
            if hasRun {
                streak += 1
                dayOffset += 1
            } else {
                break
            }
        }
        return streak
    }

    // MARK: - Persistence
    private func saveHistory() {
        do {
            let data = try JSONEncoder().encode(history)
            UserDefaults.standard.set(data, forKey: historyKey)
        } catch {
            print("Failed to save history: \(error)")
        }
    }

    private func loadHistory() -> [Run] {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else { return [] }
        do {
            let runs = try JSONDecoder().decode([Run].self, from: data)
            return runs.sorted { $0.completedAt > $1.completedAt }
        } catch {
            print("Failed to load history: \(error)")
            return []
        }
    }
}
