import re

with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    code = f.read()

target = '            "Settings": [.chinese: "设置", .english: "Settings"],'
insertion = """            "Settings": [.chinese: "设置", .english: "Settings"],
            "Developer (Test Only)": [.chinese: "开发者 (仅供测试)", .english: "Developer (Test Only)"],
            "Mock Premium Status": [.chinese: "模拟高级版状态", .english: "Mock Premium Status"],"""

code = code.replace(target, insertion)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(code)
