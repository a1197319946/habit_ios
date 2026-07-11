import re

with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    code = f.read()

old_trans = """            "This Week": [.chinese: "本周", .english: "This Week"],
            "This Month": [.chinese: "本月", .english: "This Month"],"""

new_trans = """            "This Week": [.chinese: "本周", .english: "This Week"],
            "This Month": [.chinese: "本月", .english: "This Month"],
            "Week": [.chinese: "周", .english: "Week"],
            "Month": [.chinese: "月", .english: "Month"],"""

code = code.replace(old_trans, new_trans)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(code)

