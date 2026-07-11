import re

with open('Sources/ArchivedHabitsView.swift', 'r') as f:
    code = f.read()

target = '        .background(Color(hex: "#F8F9FA").ignoresSafeArea())'
insertion = '        .background(AmbientBackground())'

code = code.replace(target, insertion)

with open('Sources/ArchivedHabitsView.swift', 'w') as f:
    f.write(code)
