import re

with open('Sources/DesignSystem.swift', 'r') as f:
    ds = f.read()

ds = re.sub(r'(static let surfaceVariant = [^\n]+)', 
            r'\1\n    static let uncheckedPlaceholder = Color(light: Color(hex: "#F3F4F6"), dark: Color(hex: "#3A3A3C"))', 
            ds)

with open('Sources/DesignSystem.swift', 'w') as f:
    f.write(ds)
