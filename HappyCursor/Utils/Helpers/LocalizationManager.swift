import Foundation

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "AppLanguage")
            updateBundle()
            updateLanguage()
        }
    }
    
    // Static supported language list
    static let supportedLanguages: [(code: String, name: String)] = [
        ("en", "English"),
        ("zh", "简体中文"),
        ("ja", "日本語"),
        ("ko", "한국어"),
        ("fr", "Français"),
        ("de", "Deutsch"),
        ("es", "Español"),
        ("ru", "Русский")
    ]
    
    private(set) var bundle: Bundle = .main
    
    private func updateBundle() {
        if let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
           let langBundle = Bundle(path: path) {
            bundle = langBundle
        } else {
            bundle = .main
        }
    }
    
    private init() {
        // Get saved language setting from UserDefaults, if not available use system language
        let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage")
        
        if let savedLanguage = savedLanguage, Self.isValidLanguageCode(savedLanguage) {
            self.currentLanguage = savedLanguage
        } else {
            // Get system language and map to our supported languages
            let systemLanguage: String
            if #available(macOS 13.0, *) {
                systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            } else {
                systemLanguage = Locale.current.languageCode ?? "en"
            }
            // Map system language to our supported languages
            self.currentLanguage = Self.mapSystemLanguageToSupported(systemLanguage)
        }
        updateBundle()
    }
    
    private func updateLanguage() {
        // Notify all views to update language
        NotificationCenter.default.post(name: .languageChanged, object: nil)
    }
    
    // Get current supported language list - use standard ISO 639-1 language codes
    var supportedLanguages: [(code: String, name: String)] {
        return Self.supportedLanguages
    }
    
    // Get localized name for language
    func localizedLanguageName(for code: String) -> String {
        switch code {
        case "en":
            return "English"
        case "zh":
            return "简体中文"
        case "ja":
            return "日本語"
        case "ko":
            return "한국어"
        case "fr":
            return "Français"
        case "de":
            return "Deutsch"
        case "es":
            return "Español"
        case "ru":
            return "Русский"
        default:
            return code
        }
    }
    
    // Validate if language code is valid
    static func isValidLanguageCode(_ code: String) -> Bool {
        return supportedLanguages.contains { $0.code == code }
    }
    
    // Map system language to our supported languages
    static func mapSystemLanguageToSupported(_ systemLanguage: String) -> String {
        // Extract base language code (remove region suffix)
        let baseLanguage = systemLanguage.split(separator: "-").first?.lowercased() ?? systemLanguage.lowercased()
        
        switch baseLanguage {
        case "zh":
            return "zh"
        case "ja":
            return "ja"
        case "ko":
            return "ko"
        case "fr":
            return "fr"
        case "de":
            return "de"
        case "es":
            return "es"
        case "ru":
            return "ru"
        case "en":
            return "en"
        default:
            return "en" // Default to English
        }
    }
}

// Extension for Notification.Name
extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

// Extension for String, providing convenient localization method, dynamically switch bundle
extension String {
    var localized: String {
        let bundle = LocalizationManager.shared.bundle
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
} 