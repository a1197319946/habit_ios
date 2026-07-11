import glob

for filename in ['Sources/HabitStatsDetailView.swift', 'Sources/HabitMonthDetailView.swift', 'Sources/HabitDetailView.swift']:
    with open(filename, 'r') as f:
        content = f.read()
    
    # Update back button foreground to primary
    content = content.replace('.foregroundColor(DS.onSurface)\n                        .padding(8)\n                        .background(DS.surface)\n                        .clipShape(Circle())', '.foregroundColor(DS.primary)\n                        .padding(8)\n                        .background(DS.surface)\n                        .clipShape(Circle())')
    
    with open(filename, 'w') as f:
        f.write(content)
