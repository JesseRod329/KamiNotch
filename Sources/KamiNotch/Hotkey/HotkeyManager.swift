import KeyboardShortcuts

@MainActor
final class HotkeyManager {
    typealias Register = (_ name: String, _ action: @escaping () -> Void) -> Void

    private let registerBlock: Register

    init(register: @escaping Register = { name, action in
        KeyboardShortcuts.onKeyUp(for: KeyboardShortcuts.Name(name), action: action)
    }) {
        self.registerBlock = register
    }

    func registerToggle(action: @escaping () -> Void) {
        registerBlock(HotkeyName.globalToggle.rawValue, action)
    }
}
