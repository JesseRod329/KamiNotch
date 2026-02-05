import AppKit

@MainActor
final class NotchHitWindowController {
    private let window: NSWindow
    private var observation: NSObjectProtocol?

    init(onTap: @escaping () -> Void) {
        let view = NotchHitView(onTap: onTap)
        window = NSWindow(
            contentRect: .zero,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .statusBar
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentView = view

        observation = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateFrame()
            }
        }
    }

    func show() {
        updateFrame()
        window.orderFrontRegardless()
    }

    func hide() {
        window.orderOut(nil)
    }

    private func updateFrame() {
        guard let screen = NSScreen.main else { return }
        window.setFrame(notchFrame(for: screen), display: true)
    }

    private func notchFrame(for screen: NSScreen) -> NSRect {
        let height = NotchGeometry.height
        let width: CGFloat = NotchGeometry.width
        let originX = screen.frame.midX - (width / 2) + NotchGeometry.panelXOffset
        let originY = screen.frame.maxY - height + NotchGeometry.panelYOffset
        return NSRect(x: originX, y: originY, width: width, height: height)
    }
}

private final class NotchHitView: NSView {
    private let onTap: () -> Void

    init(onTap: @escaping () -> Void) {
        self.onTap = onTap
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func mouseDown(with event: NSEvent) {
        onTap()
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        self
    }
}
