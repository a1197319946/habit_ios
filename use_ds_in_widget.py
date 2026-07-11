import re

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    code = f.read()

code = code.replace('colorScheme == .dark ? Color(hex: "#1C1C1E") : Color(hex: "#F9FAFC")', 'DS.bgPrimary')

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(code)

