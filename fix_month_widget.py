import re

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    code = f.read()

# 1. Remove the Button wrapping the icon, keeping just the ZStack, and change alignment to .firstTextBaseline
old_layout = """        HStack(spacing: 12) {
            VStack(spacing: 16) {
                Text(monthStr).font(.system(size: 14, weight: .heavy)).foregroundColor(Color.primary).lineLimit(1).minimumScaleFactor(0.8)
                
                Button(intent: CheckinHabitIntent(habitId: habit.id)) {
                    ZStack {
                        if todayIsDone {
                            Image(systemName: "checkmark.circle.fill").resizable().foregroundColor(.green).frame(width: 60, height: 60)
                        } else {
                            Circle().stroke(Color(hex: habit.color), lineWidth: 3).frame(width: 60, height: 60)
                            Image(systemName: habit.icon).font(.system(size: 26)).foregroundColor(Color(hex: habit.color))
                        }
                    }
                }.buttonStyle(PlainButtonStyle())
                
                Text(habit.name).font(.system(size: 16, weight: .bold)).lineLimit(1).foregroundColor(Color.primary)
            }
            .frame(width: 90)"""

new_layout = """        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(spacing: 16) {
                Text(monthStr).font(.system(size: 14, weight: .heavy)).foregroundColor(Color.primary).lineLimit(1).minimumScaleFactor(0.8)
                
                ZStack {
                    Circle().stroke(Color(hex: habit.color), lineWidth: 3).frame(width: 60, height: 60)
                    Image(systemName: habit.icon).font(.system(size: 26)).foregroundColor(Color(hex: habit.color))
                }
                
                Text(habit.name).font(.system(size: 16, weight: .bold)).lineLimit(1).foregroundColor(Color.primary)
            }
            .frame(width: 90)"""

code = code.replace(old_layout, new_layout)

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(code)

