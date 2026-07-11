import re

with open('Sources/HabitListView.swift', 'r') as f:
    code = f.read()

target = """                        NavigationLink(value: "archived_habits") {
                            Image(systemName: "archivebox")
                                .font(.system(size: 20))
                                .foregroundColor(DS.onSurfaceVariant)
                                .padding(8)"""

insertion = """                        NavigationLink(value: "archived_habits") {
                            Image(systemName: "archivebox")
                                .font(.system(size: 20))
                                .foregroundColor(DS.primary)
                                .padding(8)"""

code = code.replace(target, insertion)

with open('Sources/HabitListView.swift', 'w') as f:
    f.write(code)
