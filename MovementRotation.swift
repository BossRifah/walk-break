import Foundation

struct MovementRotation {
    static let movements = [
        "100 hops", "10 squats", "10 lunges per leg", "Rotate your waist",
        "Cat–cow", "Plank walk to downward-facing dog", "Just walk"
    ]

    private static let groups = movements.indices.flatMap { first in
        ((first + 1)..<movements.count).flatMap { second in
            ((second + 1)..<movements.count).map { third in [first, second, third] }
        }
    }
    private let defaults: UserDefaults
    private let queueKey = "movementRotation.queue"
    private let lastKey = "movementRotation.lastGroup"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func next(isTest: Bool) -> [String] {
        if isTest { return Self.movements.shuffled().prefix(3).map { $0 } }

        var queue = defaults.array(forKey: queueKey) as? [Int] ?? []
        let groups = Self.groups
        if queue.isEmpty || !queue.allSatisfy(groups.indices.contains) || Set(queue).count != queue.count {
            queue = groups.indices.shuffled()
            if let last = defaults.object(forKey: lastKey) as? Int, queue.first == last {
                queue.swapAt(0, 1)
            }
        }
        let index = queue.removeFirst()
        defaults.set(queue, forKey: queueKey)
        defaults.set(index, forKey: lastKey)
        return groups[index].shuffled().map { Self.movements[$0] }
    }
}
