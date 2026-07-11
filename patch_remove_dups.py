with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    lines = f.readlines()

new_lines = []
keys_seen = set()

import re

for line in lines:
    match = re.match(r'^\s*"([^"]+)":', line)
    if match:
        key = match.group(1)
        if key in keys_seen:
            continue
        keys_seen.add(key)
    new_lines.append(line)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write("".join(new_lines))
