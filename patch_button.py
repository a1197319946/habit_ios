with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    content = f.read()

import re

# Find the Spacer in SingleHabitWidgetView and add a Button for checkin
old_header = """            HStack {
                Text(habit.icon)
                    .font(.title)
                VStack(alignment: .leading) {
                    Text(habit.name)
                        .font(.headline)
                        .foregroundColor(DS.textPrimary)
                    Text("\\(completedAmount)/\\(habit.targetAmount) \\(habit.frequencyType == "daily" ? "times" : habit.targetUnit)")
                        .font(.caption)
                        .foregroundColor(DS.textSecondary)
                }
                Spacer()
            }"""

new_header = """            HStack {
                Text(habit.icon)
                    .font(.title)
                VStack(alignment: .leading) {
                    Text(habit.name)
                        .font(.headline)
                        .foregroundColor(DS.textPrimary)
                    Text("\\(completedAmount)/\\(habit.targetAmount) \\(habit.frequencyType == "daily" ? "times" : habit.targetUnit)")
                        .font(.caption)
                        .foregroundColor(DS.textSecondary)
                }
                Spacer()
                Button(intent: CheckinHabitIntent(habitId: habit.id)) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(isCompleted ? Color(hex: habit.color) : DS.textSecondary)
                }
                .buttonStyle(.plain)
            }"""

content = content.replace(old_header, new_header)

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(content)
