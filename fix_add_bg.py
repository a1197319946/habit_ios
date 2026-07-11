import re

with open('Sources/HabitDetailView.swift', 'r') as f:
    content = f.read()

content = content.replace("ZStack(alignment: .bottom) {", "ZStack(alignment: .bottom) {\n            DS.bgPrimary.ignoresSafeArea()")
content = content.replace("stroke(Color.white, lineWidth: 1)", "stroke(DS.outline, lineWidth: 1)")

with open('Sources/HabitDetailView.swift', 'w') as f:
    f.write(content)

