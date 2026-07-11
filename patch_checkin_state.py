import re

with open('Sources/HomeView.swift', 'r') as f:
    content = f.read()

# 1. Update isHabitChecked in HomeView
old_is_habit_checked = """    private func isHabitChecked(habit: Habit) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        return checkins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateString })
    }"""

new_is_habit_checked = """    private func isHabitChecked(habit: Habit) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        if habit.goalType == "amount" {
            let hCheckins = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateString }
            let sum = hCheckins.reduce(0) { $0 + $1.amount }
            return sum >= habit.amountValue
        } else {
            return checkins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateString })
        }
    }"""
content = content.replace(old_is_habit_checked, new_is_habit_checked)

# 2. Update isChecked in ListHabitCard
old_is_checked = """    var isChecked: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        return checkins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateString })
    }"""

new_is_checked = """    var isChecked: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        if habit.goalType == "amount" {
            let hCheckins = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateString }
            let sum = hCheckins.reduce(0) { $0 + $1.amount }
            return sum >= habit.amountValue
        } else {
            return checkins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateString })
        }
    }"""
content = content.replace(old_is_checked, new_is_checked)

with open('Sources/HomeView.swift', 'w') as f:
    f.write(content)
