import Foundation

enum PanelSizePreset: String, CaseIterable {
    case compact
    case tall
    case full
}

@MainActor
final class PanelState: ObservableObject {
    @Published var isVisible = false
    @Published var sizePreset: PanelSizePreset = .compact

    func toggle() {
        isVisible.toggle()
    }
}
