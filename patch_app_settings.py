import re
with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    content = f.read()

# Update AppLanguage display names
old_lang = """enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case english = "en"
    case chinese = "zh"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "跟随系统 (System)"
        case .english: return "English"
        case .chinese: return "中文 (Chinese)"
        }
    }
}"""
new_lang = """enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case english = "en"
    case chinese = "zh"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "系统"
        case .english: return "EN"
        case .chinese: return "中文"
        }
    }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var id: String { self.rawValue }
    
    func displayName(in language: AppLanguage) -> String {
        switch self {
        case .system: return "System".tr(language)
        case .light: return "Light".tr(language)
        case .dark: return "Dark".tr(language)
        }
    }
}"""
content = content.replace(old_lang, new_lang)

# Update AppSettings
old_settings = """class AppSettings: ObservableObject {
    @AppStorage("appLanguage") var language: AppLanguage = .system
    @AppStorage("themeColorHex") var themeColorHex: String = "#5e4dbb"
    
    var locale: Locale? {"""
new_settings = """class AppSettings: ObservableObject {
    @AppStorage("appLanguage") var language: AppLanguage = .system
    @AppStorage("themeColorHex") var themeColorHex: String = "#5e4dbb"
    @AppStorage("themeMode") var themeMode: AppTheme = .system
    @AppStorage("firstWeekday") var firstWeekday: Int = 2 // 2 = Monday, 1 = Sunday
    
    var locale: Locale? {"""
content = content.replace(old_settings, new_settings)

# Add translations for System, Light, Dark, Monday, Sunday, Appearance, Week Start
translations = """
            "System": [.chinese: "系统", .english: "System"],
            "Light": [.chinese: "浅色", .english: "Light"],
            "Dark": [.chinese: "深色", .english: "Dark"],
            "Appearance": [.chinese: "外观", .english: "Appearance"],
            "Start of Week": [.chinese: "一周开始", .english: "Start of Week"],
            "Monday": [.chinese: "周一", .english: "Monday"],
            "Sunday": [.chinese: "周日", .english: "Sunday"],
            "Cancel": [
"""
content = content.replace('            "Cancel": [', translations)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(content)

