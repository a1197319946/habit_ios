with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    content = f.read()

content = content.replace('.id(appSettings.themeColorHex)', '')
content = content.replace('.id(appSettings.themeMode.rawValue) // Global reload on theme change', '')

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(content)
