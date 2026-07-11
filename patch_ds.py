import re

with open('Sources/DesignSystem.swift', 'r') as f:
    ds = f.read()

if "uncheckedPlaceholder" not in ds:
    ds = ds.replace("static let surfaceVariant = Color(hex: \"#F3F4F6\")", "static let surfaceVariant = Color(hex: \"#F3F4F6\")\n    static let uncheckedPlaceholder = Color(UIColor.systemGray5)")

with open('Sources/DesignSystem.swift', 'w') as f:
    f.write(ds)
