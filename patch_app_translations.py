import re
with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    app_content = f.read()

new_translations = """
            "Frequency Goal": [.chinese: "次数目标", .english: "Frequency Goal"],
            "Amount Goal": [.chinese: "总量目标", .english: "Amount Goal"],
            "公里": [.chinese: "公里", .english: "km"],
            "米": [.chinese: "米", .english: "m"],
            "分钟": [.chinese: "分钟", .english: "min"],
            "小时": [.chinese: "小时", .english: "hr"],
            "次": [.chinese: "次", .english: "times"],
            "页": [.chinese: "页", .english: "pages"],
            "天": [.chinese: "天", .english: "Days"],
            "Cancel": [
"""
app_content = app_content.replace('            "Cancel": [', new_translations)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(app_content)
