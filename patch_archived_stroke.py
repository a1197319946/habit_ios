import re

with open('Sources/ArchivedHabitsView.swift', 'r') as f:
    code = f.read()

target = '                .stroke(Color.white, lineWidth: 1)'
insertion = '                .stroke(DS.outlineVariant, lineWidth: 1)'

code = code.replace(target, insertion)

with open('Sources/ArchivedHabitsView.swift', 'w') as f:
    f.write(code)
