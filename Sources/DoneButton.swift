import AppKit

final class DoneButton: NSButton {
    private var hoverArea: NSTrackingArea?
    var restingColor: NSColor = .white
    var hoverColor: NSColor = .white

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let hoverArea { removeTrackingArea(hoverArea) }

        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways, .inVisibleRect]
        let area = NSTrackingArea(rect: .zero, options: options, owner: self, userInfo: nil)
        addTrackingArea(area)

        hoverArea = area
    }

    override func resetCursorRects() {
        super.resetCursorRects()
        addCursorRect(visibleRect, cursor: .pointingHand)
    }

    override func mouseEntered(with event: NSEvent) {
        layer?.backgroundColor = hoverColor.cgColor
        NSCursor.pointingHand.set()
    }

    override func mouseExited(with event: NSEvent) {
        layer?.backgroundColor = restingColor.cgColor
        NSCursor.arrow.set()
    }
}
