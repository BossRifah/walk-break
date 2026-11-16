import AppKit

let output = URL(fileURLWithPath: CommandLine.arguments[1])
let iconSizes = [
    ("icp4", 16), ("icp5", 32), ("icp6", 64), ("ic07", 128),
    ("ic08", 256), ("ic09", 512), ("ic10", 1024),
    ("ic11", 32), ("ic12", 64), ("ic13", 256), ("ic14", 512)
]
var images = Data()

let rabbit = [
    ".....oooo.......oo..",
    "....owwpo......owpo.",
    "....owpwo.....owwpo.",
    "....owpwo....owwpo..",
    "....owwwo...owwpo...",
    ".....owwo..owwpo....",
    ".....owwo.owwoo.....",
    ".....owwwooo........",
    ".....owwwwwooo......",
    "....owwwwwwowwo.....",
    "....owwwwwwwwwo.....",
    "...owwwwwwwwwo......",
    "..owwwwwwwwso.......",
    ".owowwwwwwwo........",
    ".owowwwwwwwo........",
    "..ooswwwwwwoo.......",
    "....owwswwwwwo......",
    ".....ooooooooo......"
]
let rabbitColors: [Character: UInt32] = [
    "o": 0x283551, "w": 0xFFF1DD, "p": 0xEAA4B4, "s": 0xC5B6C6
]

func appendChunk(_ type: String, payload: Data, to output: inout Data) {
    output.append(contentsOf: type.utf8)
    var size = UInt32(payload.count + 8).bigEndian
    withUnsafeBytes(of: &size) { output.append(contentsOf: $0) }
    output.append(payload)
}

for (type, pixels) in iconSizes {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
                                  bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                  colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    let scale = CGFloat(pixels) / 32
    func color(_ rgb: UInt32) -> NSColor {
        NSColor(srgbRed: CGFloat(rgb >> 16) / 255,
                green: CGFloat((rgb >> 8) & 255) / 255,
                blue: CGFloat(rgb & 255) / 255, alpha: 1)
    }
    func paint(_ rgb: UInt32, _ x: Int, _ y: Int, _ width: Int = 1, _ height: Int = 1) {
        let left = (CGFloat(x) * scale).rounded()
        let right = (CGFloat(x + width) * scale).rounded()
        let bottom = (CGFloat(32 - y - height) * scale).rounded()
        let top = (CGFloat(32 - y) * scale).rounded()
        color(rgb).setFill()
        NSBezierPath.fill(NSRect(x: left, y: bottom, width: right - left, height: top - bottom))
    }

    let tile = NSBezierPath(roundedRect: NSRect(x: scale, y: scale, width: scale * 30, height: scale * 30),
                            xRadius: scale * 7, yRadius: scale * 7)
    tile.addClip()
    paint(0x1B3F73, 1, 1, 30, 30)
    paint(0xA9D3E3, 3, 3, 26, 26)
    paint(0xCFEBED, 3, 3, 26, 4)
    paint(0x82ABC3, 3, 23, 26, 6)
    paint(0x7299B3, 3, 27, 26, 2)
    for (row, line) in rabbit.enumerated() {
        for (column, pixel) in line.enumerated() {
            if let shade = rabbitColors[pixel] {
                paint(shade, 2 + column, 3 + row)
            }
        }
    }
    paint(0x283551, 17, 12, 12, 9)
    paint(0x789FBD, 18, 13, 10, 7)
    paint(0xBFE3E8, 19, 14, 8, 5)
    if pixels >= 32 {
        paint(0x53769D, 20, 15, 5, 1)
        paint(0x89AFC6, 20, 17, 6, 1)
    }
    paint(0x283551, 14, 20, 15, 3)
    paint(0x789FBD, 15, 20, 12, 1)
    paint(0xFFF1DD, 13, 18, 4, 2)
    paint(0xFFF1DD, 14, 19, 5, 1)

    paint(0x283551, 9, 25, 15, 3)
    paint(0xE3D1D4, 12, 26, 9, 1)
    paint(0x283551, 7, 23, 6, 6)
    paint(0x283551, 20, 23, 6, 6)
    paint(0xCE7F99, 8, 24, 4, 4)
    paint(0xCE7F99, 21, 24, 4, 4)

    NSGraphicsContext.restoreGraphicsState()
    let png = bitmap.representation(using: .png, properties: [:])!
    appendChunk(type, payload: png, to: &images)
}

var icon = Data()
appendChunk("icns", payload: images, to: &icon)
try icon.write(to: output)
