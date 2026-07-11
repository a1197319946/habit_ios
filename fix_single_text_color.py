with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    content = f.read()

# Replace all Color(hex: "#1C1C1E") inside SingleHabitWidgetView to Color.white
# Actually just search for it and replace with .white
old_text = 'Text(habit.name).font(.system(size: 16, weight: .bold)).lineLimit(1).foregroundColor(Color(hex: "#1C1C1E"))'
new_text = 'Text(habit.name).font(.system(size: 16, weight: .bold)).lineLimit(1).foregroundColor(.white)'
content = content.replace(old_text, new_text)

old_amount = 'foregroundColor(Color(hex: "#1C1C1E").opacity(0.8))'
new_amount = 'foregroundColor(.white.opacity(0.8))'
content = content.replace(old_amount, new_amount)

old_button = 'foregroundColor(isDone ? .green : Color(hex: "#1C1C1E"))'
new_button = 'foregroundColor(isDone ? .green : .white)'
content = content.replace(old_button, new_button)

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(content)
