import re

with open('Sources/HomeView.swift', 'r') as f:
    code = f.read()

# Replace the text translations
old_text = """Text(habit.frequencyType == "weekly" ? "This Week".tr(appSettings.resolvedLanguage) : "This Month".tr(appSettings.resolvedLanguage))"""
new_text = """Text(habit.frequencyType == "weekly" ? "Week".tr(appSettings.resolvedLanguage) : "Month".tr(appSettings.resolvedLanguage))"""
code = code.replace(old_text, new_text)

# Remove Spacer() before the check-in button
old_spacer = """                }
                
                Spacer()
                
                // Check-in Button"""
new_spacer = """                }
                
                // Check-in Button"""
code = code.replace(old_spacer, new_spacer)

with open('Sources/HomeView.swift', 'w') as f:
    f.write(code)

