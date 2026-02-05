import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section("Hotkey") {
                KeyboardShortcuts.Recorder(for: HotkeyName.globalToggle)
            }
        }
        .padding(24)
        .frame(width: 420)
    }
}
