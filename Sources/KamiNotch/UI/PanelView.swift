import SwiftUI

struct PanelView: View {
    @EnvironmentObject var panelState: PanelState

    var body: some View {
        VStack(spacing: 12) {
            Picker("Size", selection: $panelState.sizePreset) {
                ForEach(PanelSizePreset.allCases, id: \.self) { preset in
                    Text(preset.rawValue.capitalized).tag(preset)
                }
            }
            .pickerStyle(.segmented)

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                Text("KamiNotch")
                    .font(.title2)
            }
            .frame(width: 600, height: 320)
        }
        .padding(16)
    }
}
