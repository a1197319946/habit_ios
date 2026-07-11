import re

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    code = f.read()

# 1. Update CheckinHabitIntent logic
old_intent = """                if targetHabit.frequencyType == "weekly" || targetHabit.frequencyType == "monthly" {
                    if let existing = todays.first { existing.amount += 1.0; existing.timestamp = today }
                    else { let newCheckin = Checkin(dateString: dateString, amount: 1.0); modelContainer.mainContext.insert(newCheckin); newCheckin.habit = targetHabit }
                } else {
                    if let existing = todays.first { existing.amount = existing.amount > 0 ? 0 : 1.0; existing.timestamp = today }
                    else { let newCheckin = Checkin(dateString: dateString, amount: 1.0); modelContainer.mainContext.insert(newCheckin); newCheckin.habit = targetHabit }
                }"""
new_intent = """                if let existing = todays.first {
                    existing.amount = existing.amount > 0 ? 0 : (targetHabit.goalType == "amount" ? targetHabit.amountValue : 1.0)
                    existing.timestamp = today
                } else {
                    let newCheckin = Checkin(dateString: dateString, amount: targetHabit.goalType == "amount" ? targetHabit.amountValue : 1.0)
                    modelContainer.mainContext.insert(newCheckin)
                    newCheckin.habit = targetHabit
                }"""
code = code.replace(old_intent, new_intent)

# 2. Update MultiHabitCheckinWidgetView styles
old_multi_check = """                                if isDone {
                                    Image(systemName: "checkmark.circle.fill").font(.system(size: 26)).foregroundColor(Color(hex: habit.color))
                                } else {
                                    Circle().stroke(Color(hex: habit.color), lineWidth: 2).frame(width: 24, height: 24)
                                }"""
new_multi_check = """                                if isDone {
                                    Image(systemName: "checkmark.circle.fill").font(.system(size: 26)).foregroundColor(.green)
                                } else {
                                    Circle().stroke(Color(hex: habit.color), lineWidth: 2).frame(width: 24, height: 24)
                                }"""
code = code.replace(old_multi_check, new_multi_check)

# 3. Update NewSingleHabitWidgetView styles
old_single_check = """                    ZStack {
                        Circle().fill(isDone ? Color(hex: habit.color) : Color(hex: habit.color).opacity(0.15)).frame(width: 56, height: 56)
                        if isDone {
                            Image(systemName: "checkmark").font(.system(size: 24, weight: .bold)).foregroundColor(.white)
                        } else {
                            Image(systemName: habit.icon).font(.system(size: 24)).foregroundColor(Color(hex: habit.color))
                        }
                    }"""
new_single_check = """                    ZStack {
                        if isDone {
                            Image(systemName: "checkmark.circle.fill").resizable().foregroundColor(.green).frame(width: 56, height: 56)
                        } else {
                            Circle().stroke(Color(hex: habit.color), lineWidth: 2).frame(width: 56, height: 56)
                            Image(systemName: habit.icon).font(.system(size: 24)).foregroundColor(Color(hex: habit.color))
                        }
                    }"""
code = code.replace(old_single_check, new_single_check)

# 4. MonthCalendarWidgetView - compact grid, aligned right, add "2026年7月"
old_month = """        HStack(spacing: 12) {
            VStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color(hex: habit.color).opacity(0.15)).frame(width: 44, height: 44)
                    Image(systemName: habit.icon).font(.system(size: 20)).foregroundColor(Color(hex: habit.color))
                }
                Text(habit.name).font(.system(size: 12, weight: .bold)).lineLimit(1)
                Spacer()
            }
            .frame(width: 50)
            
            VStack(spacing: 4) {"""

new_month = """        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月"
        let monthStr = dateFormatter.string(from: date)
        
        HStack(spacing: 8) {
            VStack(spacing: 6) {
                Text(monthStr).font(.system(size: 10, weight: .medium)).foregroundColor(.gray)
                ZStack {
                    Circle().fill(Color(hex: habit.color).opacity(0.15)).frame(width: 36, height: 36)
                    Image(systemName: habit.icon).font(.system(size: 16)).foregroundColor(Color(hex: habit.color))
                }
                Text(habit.name).font(.system(size: 12, weight: .bold)).lineLimit(1)
                Spacer()
            }
            .frame(width: 60)
            Spacer(minLength: 0)
            VStack(spacing: 3) {"""
code = code.replace(old_month, new_month)

# Replace month grid size (frame 18 -> 14)
code = code.replace('.frame(width: 18, height: 18)', '.frame(width: 14, height: 14)')
code = code.replace('font(.system(size: 9', 'font(.system(size: 8')


# 5. MultiHabitWeekWidgetView - align right, match StatisticsView (RoundedRectangle), no Spacer stretching
old_multi_week = """            ForEach(selectedHabits) { habit in
                HStack(spacing: 6) {
                    HStack(spacing: 4) {
                        ZStack {
                            Circle().fill(Color(hex: habit.color).opacity(0.15)).frame(width: 20, height: 20)
                            Image(systemName: habit.icon).font(.system(size: 10)).foregroundColor(Color(hex: habit.color))
                        }
                        Text(habit.name).font(.system(size: 12, weight: .bold)).lineLimit(1)
                        Spacer()
                    }
                    .frame(width: 60, alignment: .leading)
                    
                    ForEach(days, id: \\.self) { day in
                        let isDone = isCheckedIn(habit: habit, date: day, checkins: entry.checkins)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isDone ? Color(hex: habit.color) : Color(UIColor.tertiarySystemFill))
                            .frame(height: 20)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            Spacer(minLength: 0)"""

new_multi_week = """            ForEach(selectedHabits) { habit in
                HStack(spacing: 6) {
                    HStack(spacing: 4) {
                        ZStack {
                            Circle().fill(Color(hex: habit.color).opacity(0.15)).frame(width: 20, height: 20)
                            Image(systemName: habit.icon).font(.system(size: 10)).foregroundColor(Color(hex: habit.color))
                        }
                        Text(habit.name).font(.system(size: 12, weight: .bold)).lineLimit(1)
                        Spacer()
                    }
                    .frame(width: 60, alignment: .leading)
                    Spacer(minLength: 0)
                    ForEach(days, id: \\.self) { day in
                        let isDone = isCheckedIn(habit: habit, date: day, checkins: entry.checkins)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isDone ? Color(hex: habit.color) : Color(UIColor.tertiarySystemFill))
                            .frame(width: 20, height: 20)
                    }
                }
            }"""
code = code.replace(old_multi_week, new_multi_week)
code = code.replace('Spacer().frame(width: 60)', 'Spacer().frame(width: 60)\n                Spacer(minLength: 0)')


with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(code)

