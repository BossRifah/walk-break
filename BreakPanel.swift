import AppKit
import SwiftUI

@MainActor
final class BreakPanel {
    private var window: NSPanel?

    var isVisible: Bool { window?.isVisible == true }

    func show(model: BreakTimer) {
        let panel = window ?? makeWindow(model: model)
        if !panel.isVisible, let screen = NSScreen.screens.first(where: {
            $0.frame.contains(NSEvent.mouseLocation)
        }) ?? NSScreen.main {
            let frame = screen.visibleFrame
            panel.setFrameOrigin(NSPoint(x: frame.maxX - panel.frame.width - 24, y: frame.minY + 24))
        }
        panel.orderFrontRegardless()
    }

    func hide() {
        window?.orderOut(nil)
    }

    private func makeWindow(model: BreakTimer) -> NSPanel {
        let panel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 384, height: 330),
                            styleMask: [.borderless, .nonactivatingPanel],
                            backing: .buffered, defer: false)
        panel.title = "Walk Break"
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        panel.contentView = BreakHostingView(rootView: BreakWindowView(model: model) { [weak model] in
            model?.dismissBreakWindow()
        })
        window = panel
        return panel
    }
}

private final class BreakHostingView<Content: View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

enum RetroPalette {
    static let blue = Color(red: 0.09, green: 0.23, blue: 0.46)
    static let cream = Color(red: 0.98, green: 0.95, blue: 0.87)
}

private struct BreakWindowView: View {
    @ObservedObject var model: BreakTimer
    let dismiss: () -> Void

    private let blue = RetroPalette.blue
    private let cream = RetroPalette.cream
    private var walking: Bool { model.phase == .walk }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("WALK BREAK")
                    .font(.system(size: 14, weight: .heavy, design: .monospaced))
                    .tracking(2)
                Spacer()
                if model.isTestPresentation {
                    Text("TEST")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                }
                Button(action: dismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .heavy))
                        .frame(width: 30, height: 26)
                        .background(Color(red: 0.71, green: 0.16, blue: 0.31), in: RoundedRectangle(cornerRadius: 4))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close break window")
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .frame(height: 40)

            ZStack(alignment: .topLeading) {
                PixelMeadow(animate: walking && model.isBreakWindowVisible)
                if walking {
                    Text(model.timerText)
                        .font(.system(size: 27, weight: .heavy, design: .monospaced).monospacedDigit())
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(cream)
                        .padding(10)
                        .accessibilityLabel("Break time remaining: \(model.timerText)")
                }
            }
            .frame(height: 154)
            .clipped()

            VStack(alignment: .leading, spacing: 6) {
                if walking {
                    Text("Movement ideas")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                    ForEach(model.ideas, id: \.self) { idea in
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(Color(red: 0.26, green: 0.45, blue: 0.31))
                                .frame(width: 5, height: 5)
                                .accessibilityHidden(true)
                            Text(idea).font(.system(size: 13, weight: .medium))
                        }
                    }
                } else {
                    Text("Break complete")
                        .font(.system(size: 19, weight: .heavy, design: .monospaced))
                    Text("Back to work · 40-minute timer started")
                        .font(.system(size: 13, weight: .medium))
                }
            }
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity, minHeight: 123, maxHeight: 123, alignment: .leading)
            .background(cream)
        }
        .foregroundStyle(blue)
        .padding([.horizontal, .bottom], 5)
        .background(blue)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: 384, height: 322)
        .preferredColorScheme(.light)
    }
}
