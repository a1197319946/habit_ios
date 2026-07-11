import re

# 1. Update DesignSystem.swift
with open('Sources/DesignSystem.swift', 'r') as f:
    ds = f.read()

if "static let uncheckedPlaceholder" not in ds:
    ds = ds.replace('static let surfaceVariant = Color(light: Color(hex: "#F3F4F6"), dark: Color(hex: "#2C2C2E"))', 
                    'static let surfaceVariant = Color(light: Color(hex: "#F3F4F6"), dark: Color(hex: "#2C2C2E"))\n    static let uncheckedPlaceholder = Color(light: Color(hex: "#F3F4F6"), dark: Color(hex: "#3A3A3C"))')

with open('Sources/DesignSystem.swift', 'w') as f:
    f.write(ds)

# 2. Replace hardcoded F3F4F6 with DS.uncheckedPlaceholder
def replace_f3f4f6(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    # Replace Color(hex: "#F3F4F6")
    content = content.replace('Color(hex: "#F3F4F6")', 'DS.uncheckedPlaceholder')
    with open(filepath, 'w') as f:
        f.write(content)

replace_f3f4f6('Sources/HabitStatsDetailView.swift')
replace_f3f4f6('Sources/StatisticsView.swift')

# 3. In HomeView.swift, they said the empty placeholder isn't visible.
with open('Sources/HomeView.swift', 'r') as f:
    home = f.read()
# Replace stroke for empty circle
old_stroke = 'Circle()\n                                    .stroke(isChecked ? Color.clear : Color(hex: habit.color).opacity(0.4), lineWidth: 2)'
new_stroke = 'Circle()\n                                    .stroke(isChecked ? Color.clear : Color(hex: habit.color).opacity(0.6), lineWidth: 2)\n                                    .background(Circle().fill(isChecked ? Color.clear : DS.uncheckedPlaceholder))'
home = home.replace(old_stroke, new_stroke)

with open('Sources/HomeView.swift', 'w') as f:
    f.write(home)

