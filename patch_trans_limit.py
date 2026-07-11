import re

with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    code = f.read()

target = '            "Create as many habits as you want": [.chinese: "突破限制，创建任意数量的习惯", .english: "Create as many habits as you want"],'
insertion = '            "Create as many habits as you want": [.chinese: "突破限制，创建任意数量的习惯（免费版最多5个）", .english: "Create as many habits as you want (Free version max 5)"],'

code = code.replace(target, insertion)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(code)
