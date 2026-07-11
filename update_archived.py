import re

with open('Sources/ArchivedHabitsView.swift', 'r') as f:
    content = f.read()

# Change background to unified secondary background
content = content.replace('.background(AmbientBackground())', '.background(Color(hex: "#F8F9FA").ignoresSafeArea())')

# Change icon size
old_icon = """                Circle()
                    .fill(Color(hex: habit.color).opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: habit.icon)
                    .font(.system(size: 20))"""

new_icon = """                Circle()
                    .fill(Color(hex: habit.color).opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: habit.icon)
                    .font(.system(size: 16))"""

content = content.replace(old_icon, new_icon)

with open('Sources/ArchivedHabitsView.swift', 'w') as f:
    f.write(content)
