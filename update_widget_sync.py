import re

# In HomeView.swift
with open('Sources/HomeView.swift', 'r') as f:
    home = f.read()
# Replace context.save() with context.save() + reload
if "WidgetCenter.shared.reloadAllTimelines()" not in home:
    home = home.replace("try? modelContext.save()", "try? modelContext.save()\n        import WidgetKit\n        WidgetCenter.shared.reloadAllTimelines()")
with open('Sources/HomeView.swift', 'w') as f:
    f.write(home)

# In HabitStatsDetailView.swift
with open('Sources/HabitStatsDetailView.swift', 'r') as f:
    stats = f.read()
if "WidgetCenter.shared.reloadAllTimelines()" not in stats:
    stats = stats.replace("try? modelContext.save()", "try? modelContext.save()\n        import WidgetKit\n        WidgetCenter.shared.reloadAllTimelines()")
with open('Sources/HabitStatsDetailView.swift', 'w') as f:
    f.write(stats)

# In HabitDetailView.swift
with open('Sources/HabitDetailView.swift', 'r') as f:
    detail = f.read()
if "WidgetCenter.shared.reloadAllTimelines()" not in detail:
    detail = detail.replace("try? modelContext.save()", "try? modelContext.save()\n            import WidgetKit\n            WidgetCenter.shared.reloadAllTimelines()")
    # For insert/save in submit()
    detail = detail.replace("isSubmitting = false", "import WidgetKit\n            WidgetCenter.shared.reloadAllTimelines()\n            isSubmitting = false")
with open('Sources/HabitDetailView.swift', 'w') as f:
    f.write(detail)

