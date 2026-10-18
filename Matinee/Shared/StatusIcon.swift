import AppKit

/// Menu bar images. Plain icons are template images so the system tints them; a badged icon
/// draws the symbol in `labelColor` (resolved at draw time for light/dark menu bars) plus a
/// red dot, because template images can't carry color.
enum StatusIcon {
    private static let badgeDiameter: CGFloat = 6

    static func symbol(_ name: String, badged: Bool) -> NSImage {
        guard badged else {
            let image = makeSymbol(name) ?? NSImage()
            image.isTemplate = true
            return image
        }

        let image = NSImage(size: NSSize(width: 20, height: 16), flipped: false) { rect in
            if let symbol = makeSymbol(name) {
                let symbolRect = NSRect(
                    x: (rect.width - symbol.size.width) / 2,
                    y: (rect.height - symbol.size.height) / 2,
                    width: symbol.size.width,
                    height: symbol.size.height
                )
                symbol.draw(in: symbolRect)
                NSColor.labelColor.set()
                symbolRect.fill(using: .sourceAtop)
            }
            drawBadge(in: rect)
            return true
        }
        image.isTemplate = false
        image.accessibilityDescription = "Matinee, update available"
        return image
    }

    static func badge() -> NSImage {
        let image = NSImage(size: NSSize(width: badgeDiameter, height: 16), flipped: false) { rect in
            drawBadge(in: rect)
            return true
        }
        image.isTemplate = false
        image.accessibilityDescription = "Update available"
        return image
    }

    private static func makeSymbol(_ name: String) -> NSImage? {
        NSImage(systemSymbolName: name, accessibilityDescription: "Matinee")?
            .withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 14, weight: .regular))
    }

    private static func drawBadge(in rect: NSRect) {
        NSColor.systemRed.setFill()
        NSBezierPath(ovalIn: NSRect(
            x: rect.maxX - badgeDiameter,
            y: rect.maxY - badgeDiameter - 1,
            width: badgeDiameter,
            height: badgeDiameter
        )).fill()
    }
}
