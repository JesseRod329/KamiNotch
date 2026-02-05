import AppKit
import KeyboardShortcuts
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let panelState = PanelState()
    private let preferences = AppPreferences()
    private let hotkeyManager = HotkeyManager()
    private let hotkeySetupWindow = HotkeySetupWindowController()
    private var statusItem: NSStatusItem?
    private var panelController: PanelWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.title = "⌘"
        item.button?.action = #selector(togglePanel)
        item.button?.target = self
        statusItem = item

        panelController = PanelWindowController(rootView: AnyView(PanelView()), panelState: panelState)

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
        if panelState.isVisible, let button = statusItem?.button {
            let frame = button.window?.convertToScreen(button.frame) ?? .zero
            let origin = CGPoint(x: frame.minX - 200, y: frame.minY - 380)
            panelController?.show(at: origin)
        } else {
            panelController?.hide()
        }
    }
}
