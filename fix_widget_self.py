with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    content = f.read()

content = content.replace('Habit\\.self', 'Habit.self')
content = content.replace('Checkin\\.self', 'Checkin.self')
content = content.replace('ArchivedHabit\\.self', 'ArchivedHabit.self')

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(content)
