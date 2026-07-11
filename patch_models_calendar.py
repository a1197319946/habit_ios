with open('Sources/Models.swift', 'r') as f:
    content = f.read()

import re

# We will replace `let calendar = Calendar.current` inside Models.swift with a custom constructed calendar reading from UserDefaults.
new_calendar = """        var calendar = Calendar.current
        calendar.firstWeekday = UserDefaults.standard.integer(forKey: "firstWeekday") == 0 ? 2 : UserDefaults.standard.integer(forKey: "firstWeekday")"""

content = content.replace("let calendar = Calendar.current", new_calendar)
# Some places might have `Calendar.current.date` directly? Let's check.

with open('Sources/Models.swift', 'w') as f:
    f.write(content)
