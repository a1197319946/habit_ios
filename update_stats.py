import re

with open('Sources/HabitStatsDetailView.swift', 'r') as f:
    content = f.read()

# Change HabitStatsDetailView icon to match HomeView
old_icon = """                        ZStack {
                            Circle()
                                .fill(Color(hex: habit.color).opacity(0.3))
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: habit.color).opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                )
                            
                            Image(systemName: habit.icon)
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(Color(hex: habit.color))
                        }"""

new_icon = """                        ZStack {
                            Circle()
                                .fill(Color(hex: habit.color).opacity(0.15))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: habit.icon)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: habit.color))
                        }"""
content = content.replace(old_icon, new_icon)

with open('Sources/HabitStatsDetailView.swift', 'w') as f:
    f.write(content)
