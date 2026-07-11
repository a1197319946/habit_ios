import re

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    code = f.read()

target = """struct MyWidgetBackground: View {
    @Environment(\\.colorScheme) var colorScheme
    var body: some View {
        colorScheme == .dark ? Color(hex: "#121212") : Color(hex: "#F9FAFC")
    }
}"""

insertion = """struct MyWidgetBackground: View {
    var body: some View {
        AmbientBackground()
    }
}"""

code = code.replace(target, insertion)

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(code)
