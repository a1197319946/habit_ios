import re

with open('Sources/CheckinSuccessView.swift', 'r') as f:
    content = f.read()

content = content.replace('Color(hex: "#F7F4EF")', 'DS.bgPrimary')
content = content.replace('Color(hex: "#2D2D2D")', 'DS.textPrimary')
content = content.replace('Color(hex: "#9B9088")', 'DS.textTertiary')
content = content.replace('Color(hex: "#EAE6E0")', 'DS.surfaceVariant')

with open('Sources/CheckinSuccessView.swift', 'w') as f:
    f.write(content)
