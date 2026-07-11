import re

with open('Sources/HabitListView.swift', 'r') as f:
    content = f.read()

# Replace the drag modifiers
old_drag = """                                    .onDrag {
                                        self.draggedHabit = habit
                                        return NSItemProvider(object: habit.id as NSString)
                                    }
                                    .onDrop(of: [.text], delegate: HabitDropDelegate(item: habit, habits: $localHabits, draggedHabit: $draggedHabit, modelContext: modelContext))"""

new_drag = """                                    .onDrag {
                                        self.draggedHabit = habit
                                        return NSItemProvider(object: habit.id as NSString)
                                    } preview: {
                                        HabitListCard(habit: habit)
                                            .frame(width: UIScreen.main.bounds.width - 32)
                                    }
                                    .onDrop(of: [.text], delegate: HabitDropDelegate(item: habit, habits: $localHabits, draggedHabit: $draggedHabit, modelContext: modelContext))
                                    .opacity(draggedHabit?.id == habit.id ? 0.01 : 1.0)"""

content = content.replace(old_drag, new_drag)

with open('Sources/HabitListView.swift', 'w') as f:
    f.write(content)
