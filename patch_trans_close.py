import re

with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    code = f.read()

target = '            "Cancel": [\n\n\n\n.chinese: "取消", .english: "Cancel"],'
insertion = '            "Cancel": [.chinese: "取消", .english: "Cancel"],\n            "Close": [.chinese: "关闭", .english: "Close"],'

code = code.replace(target, insertion)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(code)
