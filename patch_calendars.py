import os
import re

files_with_appsettings = [
    'Sources/HomeView.swift',
    'Sources/HabitMonthDetailView.swift',
    'Sources/HabitStatsDetailView.swift',
    'Sources/StatisticsView.swift'
]

for filepath in files_with_appsettings:
    with open(filepath, 'r') as f:
        content = f.read()
    
    # We replace `Calendar.current` with `appSettings.customCalendar`
    # if appSettings is available in the view.
    # Note: HabitStatsDetailView might not have @EnvironmentObject AppSettings.
    
    content = content.replace('Calendar.current', 'appSettings.customCalendar')
    
    with open(filepath, 'w') as f:
        f.write(content)
