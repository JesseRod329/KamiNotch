import AppKit
import Combine
import SwiftUI

@MainActor
final class PanelWindowController {
    private let panel: NSPanel
    private var observation: Any?
    private var anchorScreen: NSScreen?

    init(
        rootView: AnyView,
        panelState: PanelState,
        terminalManager: TerminalSessionManager,
        workspaceStore: WorkspaceStore,
        themeStore: ThemeStore
    ) {
        let contentView = NSHostingView(
            rootView: rootView
                .environmentObject(panelState)
                .environmentObject(terminalManager)
                .environmentObject(workspaceStore)
                .environmentObject(themeStore)
        )
        let initialSize = panelState.sizePreset.baseSize
        panel = NotchPanel(
            contentRect: NSRect(x: 0, y: 0, width: initialSize.width, height: initialSize.height),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = contentView

        observation = panelState.$sizePreset.sink { [weak self] preset in
            self?.resize(for: preset)
        }
    }

    private func resize(for preset: PanelSizePreset) {
        guard let screen = anchorScreen ?? panel.screen ?? NSScreen.main else {
            var frame = panel.frame
            frame.size = preset.baseSize
            panel.setFrame(frame, display: true, animate: true)
            return
        }

        if preset == .full {
            let frame = screen.visibleFrame
            panel.setFrame(frame, display: true, animate: true)
            return
        }

        let maxSize = screen.visibleFrame.size
        let size = preset.baseSize
        let clamped = CGSize(
            width: min(size.width, maxSize.width * 0.98),
            height: min(size.height, maxSize.height * 0.98)
        )
        var frame = panel.frame
        frame.size = clamped
        panel.setFrame(frame, display: true, animate: true)
        positionUnderNotch(on: screen)
    }

    func show(on screen: NSScreen?) {
        let targetScreen = screen ?? NSScreen.main
        anchorScreen = targetScreen
        resize(for: panelState.sizePreset)
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func hide() {
        panel.orderOut(nil)
    }

    private func positionUnderNotch(on screen: NSScreen) {
        let menuBarHeight = screen.frame.maxY - screen.visibleFrame.maxY
        let topInset = max(menuBarHeight, 28)
        let width = panel.frame.width
        let height = panel.frame.height
        let originX = screen.frame.midX - (width / 2)
        let originY = screen.frame.maxY - topInset - height - 6
        panel.setFrameOrigin(CGPoint(x: originX, y: originY))
    }
}

private final class NotchPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
