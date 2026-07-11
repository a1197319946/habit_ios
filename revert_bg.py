import re

files = ['Sources/HabitDetailView.swift', 'Sources/ArchivedHabitsView.swift', 'Sources/HabitMonthDetailView.swift', 'Sources/HabitStatsDetailView.swift']

for file in files:
    with open(file, 'r') as f:
        content = f.read()
    
    content = content.replace('AmbientBackground()', 'Color(hex: "#F8F9FA").ignoresSafeArea()')
    content = content.replace('.background(AmbientBackground())', '.background(Color(hex: "#F8F9FA").ignoresSafeArea())')
    
    with open(file, 'w') as f:
        f.write(content)
