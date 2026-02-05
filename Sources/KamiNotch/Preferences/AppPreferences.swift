import Foundation

final class AppPreferences {
    private let userDefaults: UserDefaults
    private let hotkeySetupKey = "hasCompletedHotkeySetup"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var hasCompletedHotkeySetup: Bool {
        get { userDefaults.bool(forKey: hotkeySetupKey) }
        set { userDefaults.set(newValue, forKey: hotkeySetupKey) }
    }

    func reset() {
        userDefaults.removeObject(forKey: hotkeySetupKey)
    }
}
