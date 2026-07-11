with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    content = f.read()

content = content.replace('\\\\.createdAt', '\\.createdAt')
content = content.replace('\\\\.widgetFamily', '\\.widgetFamily')
content = content.replace('\\\\.self', '\\.self')

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(content)
