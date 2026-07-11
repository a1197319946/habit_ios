import re

with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    code = f.read()

old_resolved = """    var resolvedLanguage: AppLanguage {
        if language == .system {
            if let langCode = Locale.current.language.languageCode?.identifier {
                if langCode.hasPrefix("zh") { return .chinese }
            }
            return .english
        }
        return language
    }"""
new_resolved = """    var resolvedLanguage: AppLanguage {
        if language == .system {
            if let firstLang = Locale.preferredLanguages.first {
                if firstLang.hasPrefix("zh") { return .chinese }
            }
            return .english
        }
        return language
    }"""
code = code.replace(old_resolved, new_resolved)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(code)

