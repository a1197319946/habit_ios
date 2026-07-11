import re

with open('Sources/HomeView.swift', 'r') as f:
    code = f.read()

old_today = """                        Text(isToday ? "Today".tr(appSettings.resolvedLanguage) : dayStr.tr(appSettings.resolvedLanguage))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(isSelected ? .white : (isToday ? DS.primary : DS.onSurfaceVariant))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)"""

new_today = """                        Text(isToday ? "Today".tr(appSettings.resolvedLanguage) : dayStr.tr(appSettings.resolvedLanguage))
                            .font(.system(size: 12, weight: isToday ? .bold : .medium))
                            .foregroundColor(isSelected ? .white : (isToday ? DS.primary : DS.onSurfaceVariant))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)"""

code = code.replace(old_today, new_today)

with open('Sources/HomeView.swift', 'w') as f:
    f.write(code)

