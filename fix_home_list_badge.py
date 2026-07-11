import re

with open('Sources/HomeView.swift', 'r') as f:
    code = f.read()

old_badge = """                        Text(habit.frequencyType == "weekly" ? "Week".tr(appSettings.resolvedLanguage) : "Month".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 10, weight: .semibold))"""

new_badge = """                        Text(habit.frequencyType == "weekly" ? "This Week".tr(appSettings.resolvedLanguage) : "This Month".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 10, weight: .semibold))"""

code = code.replace(old_badge, new_badge)

with open('Sources/HomeView.swift', 'w') as f:
    f.write(code)

