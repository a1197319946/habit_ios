import re

with open('Sources/HabitStatsDetailView.swift', 'r') as f:
    code = f.read()

old_stat = """            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(DS.onSurface)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text(unit)
                        .font(.system(size: 12))
                        .foregroundColor(DS.onSurfaceVariant)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(DS.onSurfaceVariant)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }"""

new_stat = """            VStack(alignment: .leading, spacing: 2) {
                (Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(DS.onSurface)
                + Text(unit.isEmpty ? "" : " \(unit)")
                    .font(.system(size: 12))
                    .foregroundColor(DS.onSurfaceVariant))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(DS.onSurfaceVariant)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }"""

code = code.replace(old_stat, new_stat)

with open('Sources/HabitStatsDetailView.swift', 'w') as f:
    f.write(code)

