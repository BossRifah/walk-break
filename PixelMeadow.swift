import AppKit
import SwiftUI

struct PixelMeadow: View {
    let animate: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Canvas { context, size in
                let field = PixelGrid(context: context, size: size)
                field.paint(.init(0xA5CEE2), 0, 0, 128, 52)

                for (x, y, width) in [(3, 8, 26), (40, 3, 18), (70, 13, 22), (101, 7, 21)] {
                    field.paint(.init(0xE9C9E0), x, y, width, 5)
                    field.paint(.init(0xE9C9E0), x + 5, y - 3, width - 9, 4)
                    field.paint(.init(0xF8E6EB), x + 5, y - 3, width - 11, 1)
                }

                for x in 0..<128 {
                    let left = 14 + abs(x - 27) / 2
                    let right = 16 + abs(x - 103) / 2
                    let ridge = min(left, right, 37) + (x % 7 > 3 ? 1 : 0)
                    field.paint(.init(0x7090C1), x, ridge, 1, 40 - ridge)
                    if ridge < 24 {
                        field.paint(.init(0xC4E0E5), x, ridge, 1, 3 + (x % 5))
                    }
                    let hill = 32 + abs(60 - x) / 18 + x % 11 / 7
                    field.paint(.init(0x6F9A82), x, hill, 1, 42 - hill)
                    let meadow = 37 + (x / 7 % 3)
                    field.paint(.init(0x9ABD72), x, meadow, 1, 52 - meadow)
                    field.paint(.init(0x608F63), x, 47 + (x * 7 % 4), 1, 5)
                }

                for x in stride(from: 2, to: 128, by: 3) {
                    let y = 47 + (x * 7 % 4)
                    field.paint(.init(0x386A57), x, y, 1, 5)
                    if x % 5 < 2 {
                        field.paint(.init(0xF8D1DE), x - 1, y - 1, 3, 1)
                        field.paint(.init(0xD492B5), x, y, 1, 1)
                    }
                }
            }

            RabbitSprite(scene: .meadow, animate: animate, reduceMotion: reduceMotion)
                .allowsHitTesting(false)
        }
        .accessibilityHidden(true)
    }
}

struct PixelDesk: View {
    let typing: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Canvas { context, size in
                let room = PixelGrid(context: context, size: size)
                room.paint(.init(0xC6CDD5), 0, 0, 128, 52)
                room.paint(.init(0xAAB8CF), 0, 0, 128, 3)
                room.paint(.init(0xAAB8CF), 0, 32, 128, 4)

                room.paint(.init(0x345172), 9, 5, 35, 25)
                room.paint(.init(0xA5CEE2), 11, 7, 31, 20)
                room.paint(.init(0xE9C9E0), 26, 10, 13, 2)
                room.paint(.init(0xF8E6EB), 29, 9, 7, 1)
                for x in 11..<42 {
                    let ridge = min(23, 14 + abs(x - 20) / 2)
                    room.paint(.init(0x7090C1), x, ridge, 1, 25 - ridge)
                    room.paint(.init(0x9ABD72), x, 23 + x / 6 % 2, 1, 3)
                }
                room.paint(.init(0x345172), 25, 7, 1, 20)
                room.paint(.init(0x345172), 11, 16, 31, 1)
                room.paint(.init(0x7490AC), 7, 29, 39, 2)

                room.paint(.init(0x7D8EAC), 0, 36, 128, 16)
                room.paint(.init(0x8C9DB6), 0, 43, 128, 1)
                room.paint(.init(0x627895), 6, 49, 116, 3)
                room.paint(.init(0x4E526C), 33, 33, 18, 11)
                room.paint(.init(0x8E778D), 35, 34, 14, 7)

                room.paint(.init(0x456A58), 108, 26, 2, 10)
                room.paint(.init(0x719370), 104, 27, 5, 2)
                room.paint(.init(0x658A68), 109, 24, 5, 2)
                room.paint(.init(0x658A68), 110, 30, 4, 2)
                room.paint(.init(0xC88680), 105, 34, 9, 5)

                room.paint(.init(0x5E4D60), 26, 39, 92, 4)
                room.paint(.init(0xA87D77), 26, 39, 92, 2)
                room.paint(.init(0x5E4D60), 31, 43, 4, 9)
                room.paint(.init(0x5E4D60), 109, 43, 4, 9)
            }

            RabbitSprite(scene: .desk, animate: typing && !reduceMotion, reduceMotion: reduceMotion)
                .allowsHitTesting(false)
        }
        .accessibilityHidden(true)
    }
}

private enum RabbitScene {
    case meadow
    case desk
}

private struct RabbitSprite: NSViewRepresentable {
    let scene: RabbitScene
    let animate: Bool
    let reduceMotion: Bool

    func makeNSView(context: Context) -> RabbitSpriteView {
        let view = RabbitSpriteView()
        view.scene = scene
        return view
    }

    func updateNSView(_ view: RabbitSpriteView, context: Context) {
        view.setAnimating(animate, reduceMotion: reduceMotion)
    }

    static func dismantleNSView(_ view: RabbitSpriteView, coordinator: ()) {
        view.setAnimating(false, reduceMotion: false)
    }
}

struct RabbitPose: Equatable {
    let x: Int
    let lift: Int
    let facingRight: Bool

    init(elapsed: TimeInterval, reduceMotion: Bool) {
        let lap = elapsed.truncatingRemainder(dividingBy: 12) / 6
        x = reduceMotion ? 54 : 8 + Int(92 * (1 - abs(1 - lap)))
        facingRight = reduceMotion || lap < 1

        let step = elapsed.truncatingRemainder(dividingBy: 0.8)
        let airborne = min(step / 0.58, 1)
        let height = reduceMotion ? 5.0 : 10.0
        lift = Int((height * sin(.pi * airborne)).rounded())
    }
}

private final class RabbitSpriteView: NSView {
    var scene: RabbitScene = .meadow
    private var ticker: Timer?
    private var startedAt = 0.0
    private var reduceMotion = false
    private var pose = RabbitPose(elapsed: 0, reduceMotion: true)
    private var typingFrame = 0

    override var isFlipped: Bool { true }

    func setAnimating(_ animate: Bool, reduceMotion: Bool) {
        self.reduceMotion = reduceMotion
        if animate {
            guard ticker == nil else { return }
            startedAt = ProcessInfo.processInfo.systemUptime
            updatePose()

            // The break panel stays non-key. Drive native redraws on the main
            // run loop even while another app has keyboard focus.
            let timer = Timer(timeInterval: 1.0 / 24, repeats: true) { [weak self] _ in
                MainActor.assumeIsolated { self?.updatePose() }
            }
            timer.tolerance = 0.006
            RunLoop.main.add(timer, forMode: .common)
            ticker = timer
        } else {
            ticker?.invalidate()
            ticker = nil
            pose = RabbitPose(elapsed: 0, reduceMotion: true)
            typingFrame = 0
            needsDisplay = true
        }
    }

    private func updatePose() {
        let elapsed = ProcessInfo.processInfo.systemUptime - startedAt
        if scene == .desk {
            let frame = Int(elapsed * 6) % 4
            guard frame != typingFrame else { return }
            typingFrame = frame
            needsDisplay = true
            return
        }
        let next = RabbitPose(elapsed: elapsed, reduceMotion: reduceMotion)
        guard next != pose else { return }
        pose = next
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let size = bounds.size
        if scene == .desk {
            drawAtDesk(size)
            return
        }
        Self.shadow.setFill()
        NSBezierPath.fill(pixelRect(size, pose.x + 3, 46, 13, 1))
        drawRabbit(size, x: pose.x, y: 31 - pose.lift, facingRight: pose.facingRight)
    }

    private func drawAtDesk(_ size: CGSize) {
        drawRabbit(size, x: 44, y: 21, facingRight: true)
        fill(0x4E435A, size, 64, 36, 26, 3)
        fill(0x8EA6C3, size, 65, 36, 23, 1)
        fill(0x4E435A, size, 72, 23, 22, 14)
        fill(0x617DA7, size, 73, 24, 20, 12)
        fill(0x8DB8D5, size, 74, 25, 18, 10)
        fill(0xE7E9E2, size, 76, 27, 9, 1)
        fill(0xC7DFE3, size, 76, 29, 12, 1)
        fill(0xC7DFE3, size, 78, 31, 7, 1)
        fill(0x4E435A, size, 60, 34, 7, 3)
        fill(0xFFF1DD, size, 60, 33 + (typingFrame % 2), 7, 2)
        fill(0xCBBBC5, size, 63, 36 - (typingFrame / 2), 6, 1)
    }

    private func fill(_ rgb: UInt32, _ size: CGSize, _ x: Int, _ y: Int, _ width: Int, _ height: Int) {
        NSColor(rgb).setFill()
        NSBezierPath.fill(pixelRect(size, x, y, width, height))
    }

    private func drawRabbit(_ size: CGSize, x: Int, y: Int, facingRight: Bool) {
        for (row, line) in Self.rabbit.enumerated() {
            for (column, pixel) in line.enumerated() {
                guard let color = Self.palette[pixel] else { continue }
                let spriteX = facingRight ? column : 18 - column
                color.setFill()
                NSBezierPath.fill(pixelRect(size, x + spriteX, y + row, 1, 1))
            }
        }
    }

    private static let shadow = NSColor(0x688A5A)
    private static let palette: [Character: NSColor] = [
        "o": .init(0x4E435A), "w": .init(0xFFF1DD), "p": .init(0xE69BB7), "s": .init(0xCBBBC5)
    ]
    private static let rabbit = [
        ".............oo....",
        "............owpo...",
        "...........owpo....",
        "..........owpo.oo..",
        "..........owo.owo..",
        "..........owoowo...",
        "..........owwwo....",
        "...oo.....owwwwoo..",
        "..owwo.ooowwwowwo..",
        "..owwoowwwwwwwwwwo.",
        "...oowwwwwwwwwwpo..",
        "....owwwwwwwsooo...",
        "....owwwwwssoo.....",
        ".....osssowwwo.....",
        ".....owwwoooo......",
        ".....oooo.........."
    ]
}

private struct PixelGrid {
    let context: GraphicsContext
    let size: CGSize

    func paint(_ color: Color, _ x: Int, _ y: Int, _ width: Int = 1, _ height: Int = 1) {
        context.fill(Path(pixelRect(size, x, y, width, height)), with: .color(color))
    }
}

private func pixelRect(_ size: CGSize, _ x: Int, _ y: Int, _ width: Int, _ height: Int) -> CGRect {
    let unitX = size.width / 128
    let unitY = size.height / 52
    let left = (CGFloat(x) * unitX).rounded()
    let top = (CGFloat(y) * unitY).rounded()
    let right = (CGFloat(x + width) * unitX).rounded()
    let bottom = (CGFloat(y + height) * unitY).rounded()
    return CGRect(x: left, y: top, width: right - left, height: bottom - top)
}

private extension Color {
    init(_ rgb: UInt32) {
        self.init(red: Double(rgb >> 16) / 255,
                  green: Double((rgb >> 8) & 255) / 255,
                  blue: Double(rgb & 255) / 255)
    }
}

private extension NSColor {
    convenience init(_ rgb: UInt32) {
        self.init(srgbRed: CGFloat(rgb >> 16) / 255,
                  green: CGFloat((rgb >> 8) & 255) / 255,
                  blue: CGFloat(rgb & 255) / 255, alpha: 1)
    }
}
