import SwiftUI

struct PanelView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
            Text("KamiNotch")
                .font(.title2)
        }
        .frame(width: 600, height: 360)
        .padding(16)
    }
}
