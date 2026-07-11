import re

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    content = f.read()

content = content.replace('func getWidgetFirstWeekday() -> Double {', 'func getWidgetFirstWeekday() -> Int {')

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(content)
