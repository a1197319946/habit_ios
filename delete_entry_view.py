with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    lines = f.readlines()

# delete lines 70 to 118
del lines[69:118]

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.writelines(lines)
