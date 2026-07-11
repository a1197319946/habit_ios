with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    content = f.read()

import re

old_code = """        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
                .environment(\\.locale, appSettings.locale ?? Locale.current)
                .id(appSettings.themeColorHex) // Global reload on theme change
        }"""

new_code = """        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
                .environment(\\.locale, appSettings.locale ?? Locale.current)
                .preferredColorScheme(appSettings.colorScheme)
                .id(appSettings.themeColorHex) // Global reload on theme change
        }"""

content = content.replace(old_code, new_code)

# Add customCalendar to AppSettings while we're in this file
old_settings = """    var resolvedLanguage: AppLanguage {
        if language == .system {"""

new_settings = """    var customCalendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = firstWeekday
        return cal
    }
    
    var resolvedLanguage: AppLanguage {
        if language == .system {"""

content = content.replace(old_settings, new_settings)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(content)
