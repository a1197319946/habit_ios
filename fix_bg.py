import re

def replace_bg(file, old, new):
    with open(file, 'r') as f:
        content = f.read()
    content = content.replace(old, new)
    with open(file, 'w') as f:
        f.write(content)

# 1. HabitStatsDetailView.swift
replace_bg('Sources/HabitStatsDetailView.swift', 'Color(hex: "#F8F9FA").ignoresSafeArea()', 'DS.bgPrimary.ignoresSafeArea()')
replace_bg('Sources/HabitStatsDetailView.swift', '.background(Color.white)', '.background(DS.surface)')

# 2. HabitMonthDetailView.swift
replace_bg('Sources/HabitMonthDetailView.swift', 'Color(hex: "#F8F9FA").ignoresSafeArea()', 'DS.bgPrimary.ignoresSafeArea()')
replace_bg('Sources/HabitMonthDetailView.swift', '.background(Color.white)', '.background(DS.surface)')

# 3. HabitDetailView.swift (Add/Edit)
replace_bg('Sources/HabitDetailView.swift', 'Color(hex: "#F8F9FA").ignoresSafeArea()', 'DS.bgPrimary.ignoresSafeArea()')
replace_bg('Sources/HabitDetailView.swift', '.background(Color.white)', '.background(DS.surface)')
replace_bg('Sources/HabitDetailView.swift', '.background(.white)', '.background(DS.surface)')

