import re

with open('Sources/HabitStatsDetailView.swift', 'r') as f:
    code = f.read()

old_header = """                            if habit.goalType == "amount" {
                                Text("\("Target: ".tr(appSettings.resolvedLanguage))\(Int(habit.weeklyTarget))\(" Times/Week".tr(appSettings.resolvedLanguage)) · \(Int(habit.amountValue))\(habit.amountUnit)")
                                    .font(.system(size: 14))
                                    .foregroundColor(DS.onSurfaceVariant)
                            } else {
                                Text("\("Target: ".tr(appSettings.resolvedLanguage))\(Int(habit.weeklyTarget))\(" Times/Week".tr(appSettings.resolvedLanguage))")
                                    .font(.system(size: 14))
                                    .foregroundColor(DS.onSurfaceVariant)
                            }"""

new_header = """                            if habit.goalType == "amount" {
                                let periodStr = habit.frequencyType == "weekly" ? "Week".tr(appSettings.resolvedLanguage) : "Month".tr(appSettings.resolvedLanguage)
                                let amtStr = String(format: "%.1f", habit.amountValue).replacingOccurrences(of: ".0", with: "")
                                Text("\("Target: ".tr(appSettings.resolvedLanguage)) \(amtStr) \(habit.amountUnit) / \(periodStr)")
                                    .font(.system(size: 14))
                                    .foregroundColor(DS.onSurfaceVariant)
                            } else {
                                let target = habit.frequencyType == "weekly" ? habit.weeklyTarget : habit.monthlyTarget
                                let periodStr = habit.frequencyType == "weekly" ? "Week".tr(appSettings.resolvedLanguage) : "Month".tr(appSettings.resolvedLanguage)
                                Text("\("Target: ".tr(appSettings.resolvedLanguage)) \(target) \("times".tr(appSettings.resolvedLanguage)) / \(periodStr)")
                                    .font(.system(size: 14))
                                    .foregroundColor(DS.onSurfaceVariant)
                            }"""

code = code.replace(old_header, new_header)

with open('Sources/HabitStatsDetailView.swift', 'w') as f:
    f.write(code)

