with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    code = f.read()

# 1. Update English weekday abbreviations to single letters
code = code.replace(
    'let weekdaysEn = sunFirst ? ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] : ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]',
    'let weekdaysEn = sunFirst ? ["S", "M", "T", "W", "T", "F", "S"] : ["M", "T", "W", "T", "F", "S", "S"]'
)

# 2. Update widget background to match app background
code = code.replace(
    'colorScheme == .dark ? Color(hex: "#1C1C1E") : Color(hex: "#F9FAFC")',
    'colorScheme == .dark ? Color(hex: "#121212") : Color(hex: "#F9FAFC")'
)

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(code)
