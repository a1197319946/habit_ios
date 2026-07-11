import re

for file in ['Sources/HomeView.swift', 'Sources/HabitStatsDetailView.swift', 'Sources/HabitDetailView.swift']:
    with open(file, 'r') as f:
        content = f.read()
    
    # Remove inline import WidgetKit
    content = content.replace("import WidgetKit\n        WidgetCenter.shared.reloadAllTimelines()", "WidgetCenter.shared.reloadAllTimelines()")
    content = content.replace("import WidgetKit\n            WidgetCenter.shared.reloadAllTimelines()", "WidgetCenter.shared.reloadAllTimelines()")
    
    # Add import at top
    if "import WidgetKit" not in content:
        content = content.replace("import SwiftUI", "import SwiftUI\nimport WidgetKit")
    
    with open(file, 'w') as f:
        f.write(content)
