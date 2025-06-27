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
    
    // 静态支持语言列表
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
        // 从UserDefaults获取保存的语言设置，如果没有则使用系统语言
        let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage")
        
        if let savedLanguage = savedLanguage, Self.isValidLanguageCode(savedLanguage) {
            self.currentLanguage = savedLanguage
        } else {
            // 获取系统语言并映射到我们支持的语言
            let systemLanguage: String
            if #available(macOS 13.0, *) {
                systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            } else {
                systemLanguage = Locale.current.languageCode ?? "en"
            }
            // 将系统语言映射到我们支持的语言
            self.currentLanguage = Self.mapSystemLanguageToSupported(systemLanguage)
        }
        updateBundle()
    }
    
    private func updateLanguage() {
        // 通知所有视图更新语言
        NotificationCenter.default.post(name: .languageChanged, object: nil)
    }
    
    // 获取当前支持的语言列表 - 使用标准的ISO 639-1语言代码
    var supportedLanguages: [(code: String, name: String)] {
        return Self.supportedLanguages
    }
    
    // 获取语言的本地化名称
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
    
    // 验证语言代码是否有效
    static func isValidLanguageCode(_ code: String) -> Bool {
        return supportedLanguages.contains { $0.code == code }
    }
    
    // 将系统语言映射到我们支持的语言
    static func mapSystemLanguageToSupported(_ systemLanguage: String) -> String {
        // 提取基础语言代码（去掉地区后缀）
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
            return "en" // 默认使用英文
        }
    }
}

// 扩展Notification.Name
extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

// 扩展String，提供便捷的本地化方法，动态切换bundle
extension String {
    var localized: String {
        let bundle = LocalizationManager.shared.bundle
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
} 