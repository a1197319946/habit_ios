with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    content = f.read()

# Fix Text(habit.icon) -> Image(systemName: habit.icon)
content = content.replace("Text(habit.icon).font(.system(size: 16))", "Image(systemName: habit.icon).font(.system(size: 16))")
content = content.replace("Text(habit.icon)", "Image(systemName: habit.icon)")

# Fix background colors in containerBackground
content = content.replace('containerBackground(for: .widget) { Color(hex: "#1C1C1E") }', 'containerBackground(for: .widget) { Color(UIColor.systemBackground) }')
content = content.replace('containerBackground(for: .widget) { Color.black }', 'containerBackground(for: .widget) { Color(UIColor.systemBackground) }')

# Fix text colors inside SingleHabitWidgetView
# We previously set text colors to .white or Color(hex: "#1C1C1E"). We should use .primary and .secondary.
content = content.replace('.foregroundColor(.white)', '.foregroundColor(.primary)')
content = content.replace('.foregroundColor(Color(hex: "#1C1C1E"))', '.foregroundColor(.primary)')
content = content.replace('.foregroundColor(.white.opacity(0.8))', '.foregroundColor(.secondary)')
content = content.replace('.foregroundColor(Color(hex: "#1C1C1E").opacity(0.8))', '.foregroundColor(.secondary)')

# In button foregroundColor(isDone ? .green : .white)
content = content.replace('.foregroundColor(isDone ? .green : .white)', '.foregroundColor(isDone ? .green : .primary)')
content = content.replace('.foregroundColor(isDone ? .green : Color(hex: "#1C1C1E"))', '.foregroundColor(isDone ? .green : .primary)')

# For MonthCalendarWidgetView
# Text(habit.name).font(.system(size: 16, weight: .bold)) -> default is primary
# ZStack checked color white -> Color.white is fine because background is habit.color (which is usually a strong color)
# ZStack text color -> isDone ? .white : Color.primary.opacity(0.5) => already good!

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(content)
