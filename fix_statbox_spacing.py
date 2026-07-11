import re

with open('Sources/HabitStatsDetailView.swift', 'r') as f:
    code = f.read()

old_statbox = """    private func statBox(icon: String, iconColor: Color, value: String, unit: String, label: String) -> some View {
        HStack(spacing: DS.spacingM) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }"""

new_statbox = """    private func statBox(icon: String, iconColor: Color, value: String, unit: String, label: String) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
            }"""

code = code.replace(old_statbox, new_statbox)
code = code.replace(".padding(DS.spacingM)\n        .background(DS.surface)", ".padding(12)\n        .background(DS.surface)")

with open('Sources/HabitStatsDetailView.swift', 'w') as f:
    f.write(code)

