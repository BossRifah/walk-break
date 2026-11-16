import AppKit
import SwiftUI
import UserNotifications

@main
struct WalkBreakApp: App {
    @StateObject private var model = BreakTimer()

    var body: some Scene {
        MenuBarExtra {
            TimerView(model: model)
        } label: {
            Label("Walk Break", systemImage: model.phase == .walk ? "figure.walk.motion" : "figure.walk")
        }
        .menuBarExtraStyle(.window)
    }
}

@MainActor
final class BreakTimer: ObservableObject {
    @Published private(set) var phase: BreakCycle.Phase?
    @Published private(set) var remaining = Int(BreakCycle.Phase.work.duration)
    @Published private(set) var notificationsBlocked = false
    @Published private(set) var ideas: [String] = []
    @Published private(set) var isBreakWindowVisible = false
    @Published private(set) var isTestPresentation = false

    private var cycle = BreakCycle()
    private var timer: Timer?
    private let notifications = BreakNotifications()
    private let panel = BreakPanel()
    private let rotation = MovementRotation()
    private var isTestCycle = false

    var timerText: String {
        String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }

    var currentDuration: TimeInterval {
        cycle.session?.duration ?? BreakCycle.Phase.work.duration
    }

    func setEnabled(_ enabled: Bool) {
        if enabled {
            start()
            Task { await refreshNotificationStatus(askIfNeeded: true) }
        } else {
            timer?.invalidate()
            timer = nil
            cycle.stop()
            dismissBreakWindow()
            refresh(at: Date())
            notifications.clear()
        }
    }

    func startTest() async {
        await refreshNotificationStatus(askIfNeeded: true)
        start(test: true)
    }

    func dismissBreakWindow() {
        panel.hide()
        isBreakWindowVisible = false
    }

    func refreshNotificationStatus(askIfNeeded: Bool = false) async {
        notificationsBlocked = await notifications.isBlocked(askIfNeeded: askIfNeeded)
    }

    private func start(test: Bool = false) {
        guard timer == nil else { return }
        let now = Date()
        isTestCycle = test
        cycle.start(at: now, test: test)
        refresh(at: now)

        let ticker = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        ticker.tolerance = 0.05
        RunLoop.main.add(ticker, forMode: .common)
        timer = ticker
    }

    private func tick() {
        let now = Date()
        let next = cycle.advanceIfDue(at: now)
        refresh(at: now)
        guard let next else { return }

        isTestPresentation = isTestCycle
        if next == .walk {
            ideas = rotation.next(isTest: isTestCycle)
        } else {
            isTestCycle = false
        }
        isBreakWindowVisible = true
        panel.show(model: self)
        notifications.send(for: next, isTest: isTestPresentation)
    }

    private func refresh(at now: Date) {
        let currentPhase = cycle.session?.phase
        let seconds = cycle.secondsRemaining(at: now)
        if phase != currentPhase { phase = currentPhase }
        if remaining != seconds { remaining = seconds }
    }
}

private final class BreakNotifications: NSObject, UNUserNotificationCenterDelegate {
    private let center = UNUserNotificationCenter.current()
    private let identifier = "walk-break-phase"

    override init() {
        super.init()
        center.delegate = self
    }

    func isBlocked(askIfNeeded: Bool) async -> Bool {
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            guard askIfNeeded else { return false }
            return (try? await center.requestAuthorization(options: [.alert, .sound])) != true
        }
        return settings.authorizationStatus == .denied || settings.alertSetting == .disabled
    }

    func send(for phase: BreakCycle.Phase, isTest: Bool) {
        let content = UNMutableNotificationContent()
        switch phase {
        case .walk:
            content.title = isTest ? "Test break started" : "Time to stand up"
            content.body = isTest ? "Your 20-second test countdown is running."
                                  : "Your 5-minute movement break has started."
        case .work:
            content.title = isTest ? "Test break complete" : "Back to work"
            content.body = "Your next 40-minute work session has started."
        }
        content.sound = .default
        center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: nil)) { error in
            if let error { NSLog("Walk Break notification: %@", error.localizedDescription) }
        }
    }

    func clear() {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}

private struct TimerView: View {
    @ObservedObject var model: BreakTimer
    @State private var isVisible = false

    private let blue = RetroPalette.blue
    private let cream = RetroPalette.cream
    private var isWalking: Bool { model.phase == .walk }
    private var isEnabled: Bool { model.phase != nil }
    private var status: String {
        if isWalking { return "Movement break" }
        return isEnabled ? "Work session" : "Ready to work"
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("WALK BREAK")
                    .font(.system(size: 14, weight: .heavy, design: .monospaced))
                    .tracking(2)
                Spacer()
                Toggle("Walk Break", isOn: Binding(
                    get: { isEnabled },
                    set: { model.setEnabled($0) }
                ))
                .toggleStyle(RetroSwitchStyle())
                .accessibilityHint("Turning this off resets the timer.")
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .frame(height: 40)

            Group {
                if isWalking {
                    PixelMeadow(animate: isVisible)
                } else {
                    PixelDesk(typing: isVisible && isEnabled)
                }
            }
            .frame(height: 130)
            .clipped()

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(status)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                        Text(model.timerText)
                            .font(.system(size: 42, weight: .heavy, design: .monospaced))
                            .monospacedDigit()
                            .accessibilityLabel("\(model.remaining / 60) minutes, \(model.remaining % 60) seconds")
                    }
                    Spacer()
                    if isEnabled {
                        Text(isWalking ? "Next: work" : "Next: break")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .padding(.bottom, 7)
                    }
                }

                progressMeter

                if isEnabled && model.notificationsBlocked {
                    Label("Allow Walk Break alerts in System Settings → Notifications.", systemImage: "bell.slash")
                        .font(.caption)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack {
                    Button("Test cycle · 25 sec") {
                        Task { await model.startTest() }
                    }
                    .disabled(isEnabled)
                    Spacer()
                    Button("Quit") {
                        model.setEnabled(false)
                        NSApplication.shared.terminate(nil)
                    }
                    .keyboardShortcut("q", modifiers: .command)
                }
                .buttonStyle(RetroButtonStyle())
                .padding(.top, 4)
            }
            .padding(12)
            .background(cream)
        }
        .foregroundStyle(blue)
        .padding([.horizontal, .bottom], 5)
        .background(blue)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: 318)
        .padding(5)
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
        .task { await model.refreshNotificationStatus() }
    }

    private var progressMeter: some View {
        let segmentCount = 18
        let remaining = Double(model.remaining) / model.currentDuration
        let filled = Int(ceil(Double(segmentCount) * remaining))
        return HStack(spacing: 2) {
            ForEach(0..<segmentCount, id: \.self) { index in
                Rectangle()
                    .fill(index < filled ? blue : blue.opacity(0.13))
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 7)
        .padding(2)
        .overlay(Rectangle().strokeBorder(blue, lineWidth: 1))
        .accessibilityHidden(true)
    }
}

private struct RetroSwitchStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 5) {
                Rectangle()
                    .fill(configuration.isOn ? Color(red: 0.70, green: 0.82, blue: 0.50) : .white.opacity(0.48))
                    .frame(width: 7, height: 7)
                Text(configuration.isOn ? "ON" : "OFF")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
            }
            .foregroundStyle(.white)
            .frame(width: 57, height: 24)
            .background(.black.opacity(0.18))
            .overlay(Rectangle().strokeBorder(.white.opacity(0.60), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityRepresentation {
            Toggle(isOn: configuration.$isOn) { configuration.label }
                .toggleStyle(.switch)
        }
    }
}

private struct RetroButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
            .padding(.horizontal, 9)
            .frame(height: 25)
            .background(configuration.isPressed ? RetroPalette.blue.opacity(0.18) : Color.white.opacity(0.28))
            .overlay(Rectangle().strokeBorder(RetroPalette.blue, lineWidth: 1))
            .opacity(isEnabled ? 1 : 0.48)
    }
}
