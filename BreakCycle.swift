import Foundation

struct BreakCycle {
    enum Phase {
        case work
        case walk

        var duration: TimeInterval {
            switch self {
            case .work: 40 * 60
            case .walk: 5 * 60
            }
        }

        var next: Self {
            self == .work ? .walk : .work
        }
    }

    struct Session {
        let phase: Phase
        let endsAt: Date
        let duration: TimeInterval
    }

    private(set) var session: Session?
    private var testing = false

    mutating func start(at now: Date, test: Bool = false) {
        testing = test
        begin(.work, duration: test ? 5 : Phase.work.duration, at: now)
    }

    mutating func stop() {
        session = nil
        testing = false
    }

    @discardableResult
    mutating func advanceIfDue(at now: Date) -> Phase? {
        guard let session, now >= session.endsAt else { return nil }
        let phase = session.phase.next
        // After sleep or a delayed tick, give the new phase its full time.
        let duration = testing && phase == .walk ? 20 : phase.duration
        if phase == .work { testing = false }
        begin(phase, duration: duration, at: now)
        return phase
    }

    func secondsRemaining(at now: Date) -> Int {
        guard let session else { return Int(Phase.work.duration) }
        let remaining = session.endsAt.timeIntervalSince(now)
        return Int(ceil(min(session.duration, max(0, remaining))))
    }

    private mutating func begin(_ phase: Phase, duration: TimeInterval, at now: Date) {
        session = Session(phase: phase, endsAt: now.addingTimeInterval(duration), duration: duration)
    }
}
