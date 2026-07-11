import re

with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    code = f.read()

target = '            "Week": [.chinese: "周", .english: "Week"],'
insertion = '            "Week": [.chinese: "本周", .english: "Week"],'

code = code.replace(target, insertion)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(code)
