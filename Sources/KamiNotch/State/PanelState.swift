import Foundation

enum PanelSizePreset: String, CaseIterable {
    case compact
    case tall
    case full

    var baseSize: CGSize {
        switch self {
        case .compact: return CGSize(width: 640, height: 380)
        case .tall: return CGSize(width: 720, height: 540)
        case .full: return CGSize(width: 900, height: 700)
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
