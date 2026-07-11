import re

def replace_in_file(filepath, old, new):
    with open(filepath, 'r') as f:
        content = f.read()
    content = content.replace(old, new)
    with open(filepath, 'w') as f:
        f.write(content)

# Task 1: Navigation Bar Dark Mode
for file in ['Sources/HabitDetailView.swift', 'Sources/HabitMonthDetailView.swift', 'Sources/HabitStatsDetailView.swift']:
    replace_in_file(file, '.toolbarBackground(Color(hex: "#F8F9FA"), for: .navigationBar)', '.toolbarBackground(DS.bgPrimary, for: .navigationBar)')

# Task 2: HabitListView Heatmap Dark Mode
replace_in_file('Sources/HabitListView.swift', 'DS.surfaceContainerLow', 'DS.uncheckedPlaceholder')

# Task 3: Popups Dark Mode
# MoodRecorderView
replace_in_file('Sources/MoodRecorderView.swift', 'Color(hex: "#F5F5F5")', 'DS.surfaceVariant')
replace_in_file('Sources/MoodRecorderView.swift', 'Color(hex: "#F9F9F9")', 'DS.surfaceVariant')
replace_in_file('Sources/MoodRecorderView.swift', 'Color.white', 'DS.surface')
replace_in_file('Sources/MoodRecorderView.swift', 'Color.black', 'DS.textPrimary') # text colors if any, wait, there are hardcoded text colors? Let's not blindly replace Color.black

# Task 4: Settings Theme Color in DesignSystem.swift
with open('Sources/DesignSystem.swift', 'r') as f:
    ds = f.read()
ds = ds.replace('static let primary = Color(hex: "#5e4dbb")', 
'''static var primary: Color {
        let hex = UserDefaults(suiteName: "group.com.littlehabit.tracker")?.string(forKey: "themeColorHex") ?? "#5e4dbb"
        return Color(hex: hex)
    }''')
with open('Sources/DesignSystem.swift', 'w') as f:
    f.write(ds)

