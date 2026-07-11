import re

with open('Sources/HabitMonthDetailView.swift', 'r') as f:
    code = f.read()

old_days_card = """                        VStack(spacing: 4) {
                            Text("\(completedDaysCount)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(DS.onSurface)
                            Text("Check-in Days".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 12))
                                .foregroundColor(DS.onSurfaceVariant)
                        }"""

new_days_card = """                        VStack(spacing: 4) {
                            Text("\(completedDaysCount)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(DS.onSurface)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            Text("Check-in Days".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 12))
                                .foregroundColor(DS.onSurfaceVariant)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }"""

old_total_card = """                            VStack(spacing: 4) {
                                Text("\(String(format: "%.1f", totalAmount).replacingOccurrences(of: ".0", with: ""))")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(DS.onSurface)
                                Text("Check-in Amount".tr(appSettings.resolvedLanguage))
                                    .font(.system(size: 12))
                                    .foregroundColor(DS.onSurfaceVariant)
                            }"""

new_total_card = """                            VStack(spacing: 4) {
                                Text("\(String(format: "%.1f", totalAmount).replacingOccurrences(of: ".0", with: ""))")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(DS.onSurface)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                Text("Check-in Amount".tr(appSettings.resolvedLanguage))
                                    .font(.system(size: 12))
                                    .foregroundColor(DS.onSurfaceVariant)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }"""

code = code.replace(old_days_card, new_days_card)
code = code.replace(old_total_card, new_total_card)

with open('Sources/HabitMonthDetailView.swift', 'w') as f:
    f.write(code)

