import re

with open('Sources/DesignSystem.swift', 'r') as f:
    ds = f.read()

# Add uncheckedPlaceholder
ds = ds.replace('static let surfaceVariant = Color(light: Color(hex: "#F3F4F6"), dark: Color(hex: "#2C2C2E"))',
                'static let surfaceVariant = Color(light: Color(hex: "#F3F4F6"), dark: Color(hex: "#2C2C2E"))\n    static let uncheckedPlaceholder = Color(light: Color(hex: "#F3F4F6"), dark: Color(hex: "#3A3A3C"))')

# Convert primary to computed property
# We only want to replace the exact declaration line.
ds = ds.replace('static let primary = Color(hex: "#5e4dbb")', 
'''static var primary: Color {
        let hex = UserDefaults(suiteName: "group.com.littlehabit.tracker")?.string(forKey: "themeColorHex") ?? "#5e4dbb"
        return Color(hex: hex)
    }''')

with open('Sources/DesignSystem.swift', 'w') as f:
    f.write(ds)

