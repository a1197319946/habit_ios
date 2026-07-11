with open('Sources/SettingsView.swift', 'r') as f:
    lines = f.readlines()

# The extra brace is at line 252
if lines[251].strip() == "}":
    lines.pop(251)

with open('Sources/SettingsView.swift', 'w') as f:
    f.writelines(lines)
