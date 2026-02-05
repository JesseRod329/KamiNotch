import AppKit
import KeyboardShortcuts
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let panelState = PanelState()
    private let preferences = AppPreferences()
    private let hotkeyManager = HotkeyManager()
    private let hotkeySetupWindow = HotkeySetupWindowController()
    private let terminalManager: TerminalSessionManager
    private let workspaceStore: WorkspaceStore
    let themeStore: ThemeStore
    private var statusItem: NSStatusItem?
    private var panelController: PanelWindowController?
    private var notchHitController: NotchHitWindowController?

    override init() {
        terminalManager = TerminalSessionManager()
        workspaceStore = WorkspaceStore(terminalManager: terminalManager)
        themeStore = ThemeStore()
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.title = "⌘"
        item.button?.action = #selector(togglePanel)
        item.button?.target = self
        statusItem = item

        panelController = PanelWindowController(
            rootView: AnyView(PanelView()),
            panelState: panelState,
            terminalManager: terminalManager,
            workspaceStore: workspaceStore,
            themeStore: themeStore
        )

        notchHitController = NotchHitWindowController(onTap: { [weak self] in
            self?.togglePanel()
        })
        notchHitController?.show()

        hotkeyManager.registerToggle(action: { [weak self] in
            self?.togglePanel()
        })

        if KeyboardShortcuts.getShortcut(for: HotkeyName.globalToggle) == nil,
           !preferences.hasCompletedHotkeySetup {
            hotkeySetupWindow.show(preferences: preferences)
        }
    }

    @objc private func togglePanel() {
        panelState.toggle()
        if panelState.isVisible {
            let screen = statusItem?.button?.window?.screen ?? NSScreen.main
            panelController?.show(on: screen)
        } else {
            panelController?.hide()
        }
    }
}
