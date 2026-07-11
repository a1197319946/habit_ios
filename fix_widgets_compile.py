import re

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    content = f.read()

# Fix 1: sum type
content = content.replace('var sum = 0', 'var sum: Double = 0')
content = content.replace('-> Int {', '-> Double {')

# Fix 2: frequencyValue
content = content.replace('let target = habit.goalType == "amount" ? Int(habit.amountValue) : habit.frequencyValue', 'let target = habit.goalType == "amount" ? Int(habit.amountValue) : (habit.frequencyType == "weekly" ? habit.weeklyTarget : habit.monthlyTarget)')
content = content.replace('let count = getCheckinsForPeriod(habit: habit, date: entry.date, checkins: entry.checkins)', 'let count = Int(getCheckinsForPeriod(habit: habit, date: entry.date, checkins: entry.checkins))')


with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(content)
