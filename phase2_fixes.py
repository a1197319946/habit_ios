import re

# Task 1: Check-in logic fix
with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    widget = f.read()

old_ischecked = """    let todays = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateStr }
    if habit.goalType == "amount" {
        return todays.reduce(0) { $0 + $1.amount } >= habit.amountValue
    }
    return !todays.isEmpty"""
new_ischecked = """    let todays = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateStr }
    if habit.goalType == "amount" {
        return todays.reduce(0) { $0 + $1.amount } >= habit.amountValue
    } else {
        return todays.reduce(0) { $0 + $1.amount } > 0
    }"""
widget = widget.replace(old_ischecked, new_ischecked)
with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(widget)


# Task 4: AppGroup for Settings
with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    app = f.read()

app = app.replace('@AppStorage("appLanguage") var language', '@AppStorage("appLanguage", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var language')
app = app.replace('@AppStorage("themeColorHex") var themeColorHex', '@AppStorage("themeColorHex", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var themeColorHex')
app = app.replace('@AppStorage("themeMode") var themeMode', '@AppStorage("themeMode", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var themeMode')
app = app.replace('@AppStorage("firstWeekday") var firstWeekday', '@AppStorage("firstWeekday", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var firstWeekday')

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(app)


# Task 5: AmountCheckinSheet Fix
with open('Sources/AmountCheckinSheet.swift', 'r') as f:
    sheet = f.read()

sheet = sheet.replace('.background(Color(hex: "#F8F9FA"))', '.background(DS.surfaceVariant)')
with open('Sources/AmountCheckinSheet.swift', 'w') as f:
    f.write(sheet)

