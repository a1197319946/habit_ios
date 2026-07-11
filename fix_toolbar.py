import re

files = ['Sources/HabitDetailView.swift', 'Sources/ArchivedHabitsView.swift', 'Sources/HabitMonthDetailView.swift', 'Sources/HabitStatsDetailView.swift']

for file in files:
    with open(file, 'r') as f:
        content = f.read()
    
    # Check if toolbarBackground is already there
    if '.toolbarBackground(.visible, for: .navigationBar)' not in content:
        # Add to the view modifiers just before .toolbar
        content = content.replace('.toolbar {', '.toolbarBackground(.visible, for: .navigationBar)\n        .toolbarBackground(Color(hex: "#F8F9FA"), for: .navigationBar)\n        .toolbar {')
        
    with open(file, 'w') as f:
        f.write(content)
