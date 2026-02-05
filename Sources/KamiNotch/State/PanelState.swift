import Foundation

enum PanelSizePreset: String, CaseIterable {
    case compact
    case tall
    case full

    var windowSize: CGSize {
        switch self {
        case .compact: return CGSize(width: 600, height: 360)
        case .tall: return CGSize(width: 680, height: 520)
        case .full: return CGSize(width: 760, height: 700)
        }
    }

    var label: String {
        rawValue.capitalized
    }
}

@MainActor
final class PanelState: ObservableObject {
    @Published var isVisible = false
    @Published var sizePreset: PanelSizePreset = .compact

    func toggle() {
        isVisible.toggle()
    }
}
