import SwiftUI

struct PanelView: View {
    @EnvironmentObject var panelState: PanelState
    @EnvironmentObject var terminalManager: TerminalSessionManager

    var body: some View {
        VStack(spacing: 12) {
            SizePresetPicker(selection: $panelState.sizePreset)

            ZStack {
                GlassBackgroundView()
                TerminalPanelView()
                    .padding(12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct SizePresetPicker: View {
    @Binding var selection: PanelSizePreset

    var body: some View {
        HStack(spacing: 6) {
            ForEach(PanelSizePreset.allCases, id: \.self) { preset in
                Button(preset.label) { selection = preset }
                    .buttonStyle(GlassPillButtonStyle(isSelected: selection == preset))
            }
        }
    }
}
