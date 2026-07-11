import re

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    code = f.read()

code = code.replace('Text(day).font(.system(size: 10, weight: .bold)).foregroundColor(.gray)\n                        .frame(maxWidth: .infinity)', 'Text(day).font(.system(size: 10, weight: .bold)).foregroundColor(.gray)\n                        .frame(width: 20)')

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(code)
