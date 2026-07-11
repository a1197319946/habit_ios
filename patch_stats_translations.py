import re
with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    app_content = f.read()

new_translations = """
            "打卡天数": [.chinese: "打卡天数", .english: "Check-in Days"],
            "总数值": [.chinese: "总数值", .english: "Total Amount"],
            "习惯详情": [.chinese: "习惯详情", .english: "Habit Details"],
            "Cancel": [
"""
app_content = app_content.replace('            "Cancel": [', new_translations)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(app_content)

with open('Sources/HabitStatsDetailView.swift', 'r') as f:
    content = f.read()

content = content.replace('unit: "天", label: "打卡天数"', 'unit: "天".tr(appSettings.resolvedLanguage), label: "打卡天数".tr(appSettings.resolvedLanguage)')
content = content.replace('unit: habit.amountUnit, label: "总数值"', 'unit: habit.amountUnit.tr(appSettings.resolvedLanguage), label: "总数值".tr(appSettings.resolvedLanguage)')
content = content.replace('Text("习惯详情")', 'Text("习惯详情".tr(appSettings.resolvedLanguage))')

with open('Sources/HabitStatsDetailView.swift', 'w') as f:
    f.write(content)

with open('Sources/HabitMonthDetailView.swift', 'r') as f:
    content = f.read()

content = content.replace('Text("习惯详情")', 'Text("习惯详情".tr(appSettings.resolvedLanguage))')

with open('Sources/HabitMonthDetailView.swift', 'w') as f:
    f.write(content)

