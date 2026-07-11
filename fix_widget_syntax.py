with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    content = f.read()

# Fix targetUnit
content = content.replace("habit.targetUnit", "habit.amountUnit")

# Fix MonthCalendarWidgetView formatter syntax
old_month = """        let days = getDaysForMonth(date: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        let monthStr = formatter.string(from: date)"""

new_month = """        let days = getDaysForMonth(date: date)
        let monthStr: String = {
            let f = DateFormatter()
            f.dateFormat = "M月"
            return f.string(from: date)
        }()"""

content = content.replace(old_month, new_month)

# Fix MultiMonthWidgetView formatter syntax
old_multi_month = """        VStack(spacing: 8) {
            HStack {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy MMM"
                Text("Monthly \\n\\(formatter.string(from: entry.date))").font(.system(size: 12, weight: .bold))"""

new_multi_month = """        VStack(spacing: 8) {
            HStack {
                let monthStr: String = {
                    let f = DateFormatter()
                    f.dateFormat = "yyyy MMM"
                    return f.string(from: entry.date)
                }()
                Text("Monthly \\n\\(monthStr)").font(.system(size: 12, weight: .bold))"""

content = content.replace(old_multi_month, new_multi_month)

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(content)
