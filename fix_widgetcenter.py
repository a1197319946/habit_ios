with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    content = f.read()

old_return = "return .result()"
new_return = "import WidgetKit\\n\\n        WidgetCenter.shared.reloadAllTimelines()\\n        return .result()"

# Only replace the last occurrence or all? Actually, there's only one in CheckinHabitIntent
if "WidgetCenter.shared.reloadAllTimelines()" not in content:
    content = content.replace(old_return, new_return)
    with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
        f.write(content)
