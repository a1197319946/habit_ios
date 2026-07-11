import re

files = ["Sources/HabitDetailView.swift", "Sources/HabitMonthDetailView.swift"]
pattern = re.compile(r'Text\("([^"]*[\u4e00-\u9fa5]+[^"]*)"\)')

for file in files:
    with open(file, 'r') as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            matches = pattern.findall(line)
            if matches:
                print(f"{file}:{i+1}: {line.strip()}")

# Also find strings that might be inside tr() but missing from LittleHabitTrackerApp.swift
