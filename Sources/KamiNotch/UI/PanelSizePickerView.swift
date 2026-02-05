import SwiftUI

struct PanelSizePickerView: View {
    @EnvironmentObject var panelState: PanelState

    var body: some View {
        HStack(spacing: 6) {
            ForEach(PanelSizePreset.allCases, id: \.self) { preset in
                Button(preset.label) { panelState.sizePreset = preset }
                    .buttonStyle(GlassPillButtonStyle(isSelected: panelState.sizePreset == preset))
            }
        }
    }
}
