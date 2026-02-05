import AppKit
import Combine
import QuartzCore
import SwiftUI

@MainActor
final class PanelWindowController {
    private let panel: NSPanel
    private var observation: Any?
    private var anchorScreen: NSScreen?
    private let panelState: PanelState
    private let expandDuration: TimeInterval = 0.28
    private let collapseDuration: TimeInterval = 0.22
    private let resizeDuration: TimeInterval = 0.20

    init(
        rootView: AnyView,
        panelState: PanelState,
        terminalManager: TerminalSessionManager,
        workspaceStore: WorkspaceStore,
        themeStore: ThemeStore
    ) {
        self.panelState = panelState
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
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.isOpaque = false
        panel.isMovable = false
        panel.hidesOnDeactivate = false
        panel.backgroundColor = .clear
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = contentView

        observation = panelState.$sizePreset.sink { [weak self] preset in
            self?.resize(for: preset)
        }
    }

    private func resize(for preset: PanelSizePreset) {
        guard let screen = anchorScreen ?? panel.screen ?? NSScreen.main else { return }
        let targetFrame = expandedFrame(for: preset, on: screen)
        if panel.isVisible {
            animateFrame(to: targetFrame, duration: resizeDuration, alpha: 1)
            return
        }
        panel.setFrame(targetFrame, display: false)
    }

    func show(on screen: NSScreen?) {
        guard let targetScreen = screen ?? NSScreen.main else { return }
        anchorScreen = targetScreen
        let start = collapsedFrame(on: targetScreen)
        let target = expandedFrame(for: panelState.sizePreset, on: targetScreen)
        panel.alphaValue = 0.95
        panel.setFrame(start, display: false)
        panel.makeKeyAndOrderFront(nil)
        animateFrame(to: target, duration: expandDuration, alpha: 1)
        NSApp.activate(ignoringOtherApps: true)
    }

    func hide() {
        guard panel.isVisible else { return }
        guard let screen = anchorScreen ?? panel.screen ?? NSScreen.main else {
            panel.orderOut(nil)
            return
        }
        let end = collapsedFrame(on: screen)
        animateFrame(to: end, duration: collapseDuration, alpha: 0.92)
        DispatchQueue.main.asyncAfter(deadline: .now() + collapseDuration) { [weak self] in
            guard let self, !self.panelState.isVisible else { return }
            self.panel.orderOut(nil)
            self.panel.alphaValue = 1
        }
    }

    private func expandedFrame(for preset: PanelSizePreset, on screen: NSScreen) -> NSRect {
        if preset == .full {
            return NSRect(
                x: screen.frame.minX,
                y: screen.frame.minY,
                width: screen.frame.width,
                height: screen.frame.height
            )
        }
        let size = clampedSize(for: preset, on: screen)
        let originX = screen.frame.midX - (size.width / 2) + NotchGeometry.panelXOffset
        let originY = screen.frame.maxY - size.height + NotchGeometry.panelYOffset
        return NSRect(x: originX, y: originY, width: size.width, height: size.height)
    }

    private func collapsedFrame(on screen: NSScreen) -> NSRect {
        let size = CGSize(width: NotchGeometry.collapsedWidth, height: NotchGeometry.collapsedHeight)
        let originX = screen.frame.midX - (size.width / 2) + NotchGeometry.panelXOffset
        let originY = screen.frame.maxY - size.height + NotchGeometry.panelYOffset
        return NSRect(x: originX, y: originY, width: size.width, height: size.height)
    }

    private func clampedSize(for preset: PanelSizePreset, on screen: NSScreen) -> CGSize {
        let maxSize = screen.frame.size
        let size = preset.baseSize
        return CGSize(
            width: min(size.width, maxSize.width * 0.98),
            height: min(size.height, maxSize.height * 0.98)
        )
    }

    private func animateFrame(
        to frame: NSRect,
        duration: TimeInterval,
        alpha: CGFloat
    ) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().setFrame(frame, display: true)
            panel.animator().alphaValue = alpha
        }
    }
}

private final class NotchPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
