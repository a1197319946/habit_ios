import re

# Fix HabitDetailView
with open('Sources/HabitDetailView.swift', 'r') as f:
    content = f.read()

content = content.replace('@State private var WidgetCenter.shared.reloadAllTimelines()\n            isSubmitting = false', '@State private var isSubmitting = false')
with open('Sources/HabitDetailView.swift', 'w') as f:
    f.write(content)

# Fix LittleHabitWidget
with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    widget = f.read()

bad_str = """        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月"
        let monthStr = dateFormatter.string(from: date)"""

good_str = """        let monthStr = {
            let f = DateFormatter()
            f.dateFormat = "yyyy年M月"
            return f.string(from: date)
        }()"""
widget = widget.replace(bad_str, good_str)
with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(widget)

