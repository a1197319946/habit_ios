import re
with open('Sources/HomeView.swift', 'r') as f:
    content = f.read()

old_block = """                        Text(progressText)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DS.onSurfaceVariant)
                        
                        Text(habit.frequencyType == "weekly" ? "This Week".tr(appSettings.resolvedLanguage) : "This Month".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 10, weight: .semibold))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)"""

new_block = """                        Spacer()
                        
                        Text(progressText)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DS.onSurfaceVariant)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                        
                        Text(habit.frequencyType == "weekly" ? "This Week".tr(appSettings.resolvedLanguage) : "This Month".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 10, weight: .semibold))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)"""

# Also remove the Spacer(minLength: 8) before this block since we added Spacer() instead
content = content.replace("                        Spacer(minLength: 8)\n                        \n" + old_block, new_block)

with open('Sources/HomeView.swift', 'w') as f:
    f.write(content)

