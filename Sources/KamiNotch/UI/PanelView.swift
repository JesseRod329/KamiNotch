import SwiftUI

struct PanelView: View {
    var body: some View {
        ZStack {
            GlassBackgroundView()
            TerminalPanelView()
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
