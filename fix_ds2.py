import re
with open('Sources/DesignSystem.swift', 'r') as f:
    content = f.read()

missing_props = """
    static let onPrimary = Color.white
"""
content = content.replace('static let background = bgPrimary', 'static let background = bgPrimary\n' + missing_props)

with open('Sources/DesignSystem.swift', 'w') as f:
    f.write(content)
