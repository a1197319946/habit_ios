with open('Sources/HabitListView.swift', 'r') as f:
    code = f.read()

code = code.replace("@State private var draggedHabit: Habit?", "@State private var draggedHabit: Habit?\n    @State private var navigateToAddHabit = false")

with open('Sources/HabitListView.swift', 'w') as f:
    f.write(code)
