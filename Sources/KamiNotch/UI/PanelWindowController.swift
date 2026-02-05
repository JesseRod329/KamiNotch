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
        panel = NotchPanel(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 360),
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
        let height: CGFloat
        switch preset {
        case .compact: height = 360
        case .tall: height = 540
        case .full: height = 720
        }
        var frame = panel.frame
        frame.size.height = height
        panel.setFrame(frame, display: true, animate: true)
        if let screen = anchorScreen ?? panel.screen {
            positionUnderNotch(on: screen)
        }
    }

    func show(on screen: NSScreen?) {
        let targetScreen = screen ?? NSScreen.main
        anchorScreen = targetScreen
        if let targetScreen {
            positionUnderNotch(on: targetScreen)
        }
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
