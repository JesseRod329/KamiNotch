import KeyboardShortcuts
import SwiftUI

@MainActor
final class HotkeySetupViewModel: ObservableObject {
    private let preferences: AppPreferences

    init(preferences: AppPreferences) {
        self.preferences = preferences
    }

    func confirmSetup() {
        preferences.hasCompletedHotkeySetup = true
    }

    func cancelSetup() {
        if KeyboardShortcuts.getShortcut(for: HotkeyName.globalToggle) == nil {
            KeyboardShortcuts.setShortcut(
                .init(.t, modifiers: [.control, .option, .command]),
                for: HotkeyName.globalToggle
            )
        }
        preferences.hasCompletedHotkeySetup = true
    }
}

struct HotkeySetupView: View {
    @ObservedObject var viewModel: HotkeySetupViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Set Your Hotkey")
                .font(.title2)
            Text("Choose a shortcut to toggle KamiNotch.")
                .foregroundStyle(.secondary)
            KeyboardShortcuts.Recorder(for: HotkeyName.globalToggle)
            HStack {
                Button("Use Default") { viewModel.cancelSetup() }
                Button("Save") { viewModel.confirmSetup() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 380)
    }
}
