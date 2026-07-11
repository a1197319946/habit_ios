import re

files = [
    'Sources/HabitMonthDetailView.swift',
    'Sources/HabitStatsDetailView.swift',
    'Sources/HomeView.swift',
    'Sources/StatisticsView.swift'
]

for filepath in files:
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Replace `private let calendar = appSettings.customCalendar` with `private var calendar: Calendar { appSettings.customCalendar }`
    content = content.replace("private let calendar = appSettings.customCalendar", "private var calendar: Calendar { appSettings.customCalendar }")
    content = content.replace("let calendar = appSettings.customCalendar", "var calendar: Calendar { appSettings.customCalendar }")
    
    # Fix currentYear init
    content = content.replace("@State private var currentYear: Int = appSettings.customCalendar.component(.year, from: Date())", "@State private var currentYear: Int = Calendar.current.component(.year, from: Date())")
    content = content.replace("@State private var currentYear = appSettings.customCalendar.component(.year, from: Date())", "@State private var currentYear = Calendar.current.component(.year, from: Date())")
    content = content.replace("self._currentMonthDate = State(initialValue: appSettings.customCalendar.date(from: comp) ?? Date())", "self._currentMonthDate = State(initialValue: Calendar.current.date(from: comp) ?? Date())")

    with open(filepath, 'w') as f:
        f.write(content)
