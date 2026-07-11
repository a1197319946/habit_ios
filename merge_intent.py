with open('Sources/LittleHabitWidget/HabitIntent.swift', 'r') as f:
    intent_code = f.read()

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    widget_code = f.read()

# Remove import AppIntents from intent_code as it's already there or we can just append
intent_code = intent_code.replace("import AppIntents\\n", "")
intent_code = intent_code.replace("import SwiftData\\n", "")
intent_code = intent_code.replace("import Foundation\\n", "")

merged = widget_code + "\\n\\n// MARK: - App Intents\\n" + intent_code

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(merged)

import os
os.remove('Sources/LittleHabitWidget/HabitIntent.swift')
