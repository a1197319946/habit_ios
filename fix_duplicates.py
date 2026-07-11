import re

with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    lines = f.readlines()

new_lines = []
seen_keys = set()
for line in lines:
    match = re.search(r'^\s*"([^"]+)": \[', line)
    if match:
        key = match.group(1)
        if key in seen_keys:
            continue
        seen_keys.add(key)
    new_lines.append(line)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.writelines(new_lines)
