import re

with open('Sources/HabitMonthDetailView.swift', 'r') as f:
    code = f.read()

old_init = """    init(habit: Habit, year: Int, month: Int) {
        self.habit = habit
        self._year = State(initialValue: year)
        self._month = State(initialValue: month)"""

new_init = """    init(habit: Habit, year: Int, month: Int) {
        self.habit = habit
        self._selectedImageForFullscreen = State(initialValue: nil)
        self._year = State(initialValue: year)
        self._month = State(initialValue: month)"""

code = code.replace(old_init, new_init)

with open('Sources/HabitMonthDetailView.swift', 'w') as f:
    f.write(code)

