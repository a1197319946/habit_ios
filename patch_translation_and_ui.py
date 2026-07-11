import re

# 1. Update Translations in LittleHabitTrackerApp.swift
with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    app_content = f.read()

new_translations = """            "Generate Sharing Image": [.chinese: "生成分享图", .english: "Generate Sharing Image"],
            "Enter Data": [.chinese: "录入打卡数据", .english: "Enter Data"],
            "Edit Data": [.chinese: "修改打卡数据", .english: "Edit Data"],
            "Period Target: ": [.chinese: "本周期目标: ", .english: "Period Target: "],
            "Period Total: ": [.chinese: "本周期已累计: ", .english: "Period Total: "],
            "Amount Completed": [.chinese: "本次完成量", .english: "Amount Completed"],
            "Save Changes": [.chinese: "保存修改", .english: "Save Changes"],
            "Undo Check-in": [.chinese: "撤销打卡", .english: "Undo Check-in"],
            "Edit Amount": [.chinese: "修改数值", .english: "Edit Amount"],
            "Cancel": [.chinese: "取消", .english: "Cancel"],
            "Show Completed": [.chinese: "显示已打卡", .english: "Show Completed"],
            "Hide Completed": [.chinese: "隐藏已打卡", .english: "Hide Completed"],
            "This Week": [.chinese: "本周", .english: "This Week"],
            "This Month": [.chinese: "本月", .english: "This Month"],
            " times": [.chinese: "次", .english: " times"],
            " time": [.chinese: "次", .english: " time"],
            "Cancel Check-in?": [.chinese: "操作", .english: "Options"],
"""
app_content = app_content.replace('            "Generate Sharing Image": [.chinese: "生成分享图", .english: "Generate Sharing Image"],', new_translations)

with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
    f.write(app_content)

# 2. Update AmountCheckinSheet.swift
with open('Sources/AmountCheckinSheet.swift', 'r') as f:
    sheet_content = f.read()

# Fix translations
sheet_content = sheet_content.replace('Text(isEditing ? "修改打卡数据" : "录入打卡数据")', 'Text(isEditing ? "Edit Data".tr(appSettings.resolvedLanguage) : "Enter Data".tr(appSettings.resolvedLanguage))')
sheet_content = sheet_content.replace('Text("本周期目标: \\(targetFormatted) \\(habit.amountUnit)")', 'Text("\\("Period Target: ".tr(appSettings.resolvedLanguage))\\(targetFormatted) \\(habit.amountUnit)")')
sheet_content = sheet_content.replace('Text("本周期已累计: \\(accFormatted) \\(habit.amountUnit)")', 'Text("\\("Period Total: ".tr(appSettings.resolvedLanguage))\\(accFormatted) \\(habit.amountUnit)")')
sheet_content = sheet_content.replace('Text("本次完成量")', 'Text("Amount Completed".tr(appSettings.resolvedLanguage))')
sheet_content = sheet_content.replace('Text(isEditing ? "保存修改" : "完成打卡")', 'Text(isEditing ? "Save Changes".tr(appSettings.resolvedLanguage) : "Check In".tr(appSettings.resolvedLanguage))')

# Fix height
sheet_content = sheet_content.replace('.presentationDetents([.height(500)])', '.presentationDetents([.height(560)])')

# Fix "02" issue
old_onAppear = """        .onAppear {
            if let initial = initialAmount {
                amountString = formatDouble(initial)
            }"""
new_onAppear = """        .onAppear {
            if let initial = initialAmount, initial > 0 {
                amountString = formatDouble(initial)
            } else {
                amountString = ""
            }"""
sheet_content = sheet_content.replace(old_onAppear, new_onAppear)

with open('Sources/AmountCheckinSheet.swift', 'w') as f:
    f.write(sheet_content)

# 3. Update HomeView.swift
with open('Sources/HomeView.swift', 'r') as f:
    home_content = f.read()

# Replace action sheet with alert
old_action_sheet = """        .confirmationDialog(
            "Cancel Check-in?",
            isPresented: $showingActionSheet,
            titleVisibility: .hidden
        ) {
            if let habit = selectedHabit {
                if habit.goalType == "amount" {
                    Button("Edit Amount") {
                        editAmount(habit: habit)
                    }
                }
                
                Button("Undo Check-in", role: .destructive) {
                    undoCheckin(habit: habit)
                }
                
                Button("Cancel", role: .cancel) {}
            }
        }"""
        
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
home_content = home_content.replace(old_action_sheet, new_alert)

# Fix translations in HomeView
home_content = home_content.replace('Text(hideCompleted ? "显示已打卡" : "隐藏已打卡")', 'Text(hideCompleted ? "Show Completed".tr(appSettings.resolvedLanguage) : "Hide Completed".tr(appSettings.resolvedLanguage))')
home_content = home_content.replace('Text(habit.frequencyType == "weekly" ? "本周" : "本月")', 'Text(habit.frequencyType == "weekly" ? "This Week".tr(appSettings.resolvedLanguage) : "This Month".tr(appSettings.resolvedLanguage))')

# Update progress text to use "次" correctly based on language
old_progress = """        } else {
            return "\\(periodCompleted)/\\(periodTarget)次"
        }"""
new_progress = """        } else {
            return "\\(periodCompleted)/\\(periodTarget)\\(" times".tr(appSettings.resolvedLanguage))"
        }"""
home_content = home_content.replace(old_progress, new_progress)

with open('Sources/HomeView.swift', 'w') as f:
    f.write(home_content)
