with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    content = f.read()

# Remove .padding() at the end of the widget views
content = content.replace("        }\n        .padding()", "        }")
content = content.replace("        }.padding()", "        }")

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(content)
