import re

with open('Sources/HomeView.swift', 'r') as f:
    content = f.read()

# Replace the confirmationDialog with alert
pattern = re.compile(r'\.confirmationDialog\([^)]+\)\s*\{[^}]*\}', re.DOTALL)
match = pattern.search(content)

if match:
    old_dialog = match.group(0)
    new_alert = """        .alert(
            "Options".tr(appSettings.resolvedLanguage),
            isPresented: $showingActionSheet,
            presenting: selectedHabit
        ) { habit in
            if habit.goalType == "amount" {
                Button("Edit Amount".tr(appSettings.resolvedLanguage)) {
                    editAmount(habit: habit)
                }
            }
            Button("Undo Check-in".tr(appSettings.resolvedLanguage), role: .destructive) {
                undoCheckin(habit: habit)
            }
            Button("Cancel".tr(appSettings.resolvedLanguage), role: .cancel) {}
        }"""
    content = content.replace(old_dialog, new_alert)
    print("Replaced confirmationDialog")
else:
    print("Could not find confirmationDialog")

with open('Sources/HomeView.swift', 'w') as f:
    f.write(content)
