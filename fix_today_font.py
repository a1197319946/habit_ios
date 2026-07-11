import re

with open('Sources/HomeView.swift', 'r') as f:
    code = f.read()

old_font = """.font(.system(size: 12, weight: isToday ? .bold : .medium))"""
new_font = """.font(.system(size: isToday ? 14 : 12, weight: isToday ? .bold : .medium))"""

code = code.replace(old_font, new_font)

with open('Sources/HomeView.swift', 'w') as f:
    f.write(code)

