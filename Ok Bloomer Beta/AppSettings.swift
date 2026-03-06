import UIKit

class AppSettings {
    static let shared = AppSettings()

    private init() {}

    // Retrieve and update dark mode status
    var isDarkModeEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "darkMode")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "darkMode")
        }
    }

    // Retrieve and update selected font
    var selectedFont: String {
        get {
            return UserDefaults.standard.string(forKey: "selectedFont") ?? "System"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedFont")
        }
    }
    
    var isSoundEnabled: Bool {
            get {
                return UserDefaults.standard.bool(forKey: "soundEnabled")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "soundEnabled")
            }
        }

    // Apply dark mode to the entire app
    func applyDarkMode() {
        let window = UIApplication.shared.windows.first
        window?.overrideUserInterfaceStyle = isDarkModeEnabled ? .dark : .light
    }
}
