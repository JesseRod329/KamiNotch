import AppKit
import SwiftUI

@MainActor
final class HotkeySetupWindowController {
    private var window: NSWindow?

    func show(preferences: AppPreferences) {
        let viewModel = HotkeySetupViewModel(preferences: preferences)
        let view = HotkeySetupView(viewModel: viewModel)
        let hosting = NSHostingView(rootView: view)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 220),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "KamiNotch"
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        self.window = window
    }
}
