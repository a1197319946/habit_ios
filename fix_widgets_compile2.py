import re

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    content = f.read()

content = content.replace('amount: 1)', 'amount: 1.0)')
content = content.replace('existing.amount += 1', 'existing.amount += 1.0')
content = content.replace('existing.amount = existing.amount > 0 ? 0 : 1', 'existing.amount = existing.amount > 0 ? 0 : 1.0')

# For getWidgetFirstWeekday fallback which might have been converted to Double:
# Actually wait, `getCheckinsForPeriod` -> `sum` is `Double`.
# Line 185 error: `cannot convert return expression of type 'Int' to return type 'Double'`. Wait, I don't know what is on line 185.
# Let's fix line 185 return. Maybe `return getWidgetFirstWeekday()`? No, `getWidgetFirstWeekday()` returns `Int`.
