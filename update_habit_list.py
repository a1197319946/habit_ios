import re

with open('Sources/HabitListView.swift', 'r') as f:
    content = f.read()

# Change FAB gradient to solid DS.primary
old_fab = """                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#9D8DFF"), Color(hex: "#B5A8FF")],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )"""
new_fab = """                            Circle()
                                .fill(DS.primary)"""
content = content.replace(old_fab, new_fab)


# Change HabitListCard Icon shape and size
old_icon = """                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(habitColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: habit.icon)
                        .foregroundColor(habitColor)
                        .font(.system(size: 20, weight: .semibold))
                }"""
new_icon = """                ZStack {
                    Circle()
                        .fill(habitColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: habit.icon)
                        .foregroundColor(habitColor)
                        .font(.system(size: 16))
                }"""
content = content.replace(old_icon, new_icon)

with open('Sources/HabitListView.swift', 'w') as f:
    f.write(content)
