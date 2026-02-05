import AppKit
import Combine
import SwiftUI

@MainActor
final class PanelWindowController {
    private let panel: NSPanel
    private var observation: Any?

    init(rootView: AnyView, panelState: PanelState) {
        let contentView = NSHostingView(rootView: rootView.environmentObject(panelState))
        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 360),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.contentView = contentView

        observation = panelState.$sizePreset.sink { [weak self] preset in
            self?.resize(for: preset)
        }
    }

    private func resize(for preset: PanelSizePreset) {
        let height: CGFloat
        switch preset {
        case .compact: height = 360
        case .tall: height = 540
        case .full: height = 720
        }
        var frame = panel.frame
        frame.size.height = height
        panel.setFrame(frame, display: true, animate: true)
    }

    func show(at origin: CGPoint) {
        panel.setFrameOrigin(origin)
        panel.orderFront(nil)
    }

    func hide() {
        panel.orderOut(nil)
    }
}
