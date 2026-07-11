import re
with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    content = f.read()

# Add a colorScheme property to AppSettings
color_scheme = """
    var colorScheme: ColorScheme? {
        switch themeMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
"""
content = content.replace('var locale: Locale? {', color_scheme + '\n    var locale: Locale? {')

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(content)

with open('Sources/ContentView.swift', 'r') as f:
    content = f.read()

content = content.replace('.environmentObject(appSettings)', '.environmentObject(appSettings)\n        .preferredColorScheme(appSettings.colorScheme)')

with open('Sources/ContentView.swift', 'w') as f:
    f.write(content)
