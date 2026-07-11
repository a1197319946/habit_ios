import re

# 1. Update SettingsView to reload Widget Timelines on themeMode change
with open('Sources/SettingsView.swift', 'r') as f:
    settings = f.read()

# Add import WidgetKit if not present
if "import WidgetKit" not in settings:
    settings = settings.replace("import SwiftUI", "import SwiftUI\nimport WidgetKit")

old_picker = """                                Picker("", selection: $appSettings.themeMode) {
                                    ForEach(AppTheme.allCases) { theme in
                                        Text(theme.displayName(in: appSettings.resolvedLanguage)).tag(theme)
                                    }
                                }"""
new_picker = """                                Picker("", selection: $appSettings.themeMode) {
                                    ForEach(AppTheme.allCases) { theme in
                                        Text(theme.displayName(in: appSettings.resolvedLanguage)).tag(theme)
                                    }
                                }
                                .onChange(of: appSettings.themeMode) { _ in
                                    WidgetCenter.shared.reloadAllTimelines()
                                }"""
if ".onChange(of: appSettings.themeMode)" not in settings:
    settings = settings.replace(old_picker, new_picker)

with open('Sources/SettingsView.swift', 'w') as f:
    f.write(settings)


# 2. Fix CheckinHabitIntent in LittleHabitWidget
with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    widget = f.read()

old_intent = """                let fillAmount = targetHabit.goalType == "amount" ? targetHabit.amountValue : 1
                if targetHabit.frequencyType == "weekly" || targetHabit.frequencyType == "monthly" {
                    if let existing = todays.first { existing.amount += 1; existing.timestamp = today }
                    else { let newCheckin = Checkin(dateString: dateString, amount: 1); modelContainer.mainContext.insert(newCheckin); newCheckin.habit = targetHabit }
                } else {
                    if let existing = todays.first { existing.amount = existing.amount > 0 ? 0 : fillAmount; existing.timestamp = today }
                    else { let newCheckin = Checkin(dateString: dateString, amount: fillAmount); modelContainer.mainContext.insert(newCheckin); newCheckin.habit = targetHabit }
                }"""

new_intent = """                let fillAmount = targetHabit.goalType == "amount" ? targetHabit.amountValue : 1
                if targetHabit.frequencyType == "weekly" || targetHabit.frequencyType == "monthly" {
                    if let existing = todays.first { existing.amount += 1; existing.timestamp = today }
                    else { let newCheckin = Checkin(dateString: dateString, amount: 1); modelContainer.mainContext.insert(newCheckin); newCheckin.habit = targetHabit }
                } else {
                    let totalAmount = todays.reduce(0, { $0 + $1.amount })
                    if totalAmount > 0 {
                        // Undo: Delete all checkin records for today to cleanly undo
                        todays.forEach { modelContainer.mainContext.delete($0) }
                    } else {
                        // Checkin
                        let newCheckin = Checkin(dateString: dateString, amount: fillAmount)
                        modelContainer.mainContext.insert(newCheckin)
                        newCheckin.habit = targetHabit
                        newCheckin.timestamp = today
                    }
                }"""

widget = widget.replace(old_intent, new_intent)
with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(widget)

