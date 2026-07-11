import re

# 1. Update Translations in LittleHabitTrackerApp.swift
with open('Sources/LittleHabitTrackerApp.swift', 'r') as f:
    app_content = f.read()

if '"Options": [' not in app_content:
    app_content = app_content.replace('"Cancel": [', '            "Options": [.chinese: "操作", .english: "Options"],\n            "Cancel": [')
    with open('Sources/LittleHabitTrackerApp.swift', 'w') as f:
        f.write(app_content)

# 2. Update HomeView header
with open('Sources/HomeView.swift', 'r') as f:
    content = f.read()

old_header = """                    // Header & Month
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(greetingString)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(DS.onSurface)
                            Text(monthString(for: selectedDate))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(DS.onSurfaceVariant)
                        }
                        
                        Spacer()
                        
                        // Small icon or today indicator could go here
                        ZStack {
                            Circle().fill(DS.primaryContainer).frame(width: 40, height: 40)
                            Image(systemName: "calendar")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(DS.primary)
                        }
                        .onTapGesture {
                            withAnimation { selectedDate = Date() }
                        }
                    }
                    .padding(.horizontal, DS.spacingL)
                    .padding(.top, DS.spacingL)"""

new_header = """                    // Header & Month
                    HStack(alignment: .lastTextBaseline, spacing: 8) {
                        Spacer()
                        
                        Text(monthString(for: selectedDate))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DS.onSurfaceVariant)
                            
                        Text(greetingString)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(DS.onSurface)
                    }
                    .padding(.horizontal, DS.spacingL)
                    .padding(.top, 8)"""
content = content.replace(old_header, new_header)

# Reduce spacing of the VStack if we want it more compact
content = content.replace('VStack(alignment: .leading, spacing: 20) {', 'VStack(alignment: .leading, spacing: 12) {')

with open('Sources/HomeView.swift', 'w') as f:
    f.write(content)
