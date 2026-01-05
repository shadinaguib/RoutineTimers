import Foundation

struct Step: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var minutes: Int

    init(id: UUID = UUID(), title: String, minutes: Int) {
        self.id = id
        self.title = title
        self.minutes = minutes
    }
}

struct Routine: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var steps: [Step]

    init(id: UUID = UUID(), name: String, steps: [Step]) {
        self.id = id
        self.name = name
        self.steps = steps
    }

    var totalMinutes: Int { steps.reduce(0) { $0 + $1.minutes } }
}

struct Run: Identifiable, Codable, Hashable {
    let id: UUID
    let routineName: String
    let completedAt: Date

    init(id: UUID = UUID(), routineName: String, completedAt: Date = Date()) {
        self.id = id
        self.routineName = routineName
        self.completedAt = completedAt
    }
}
