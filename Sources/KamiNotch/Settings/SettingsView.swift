import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            Form {
                Section("Hotkey") {
                    KeyboardShortcuts.Recorder(for: HotkeyName.globalToggle)
                }
            }
            .tabItem { Text("General") }

            ThemeSettingsView()
                .tabItem { Text("Theme") }
        }
    }
}
