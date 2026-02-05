import Foundation

@MainActor
final class PanelState: ObservableObject {
    @Published var isVisible = false
}
