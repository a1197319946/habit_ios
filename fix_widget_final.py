import re

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    code = f.read()

# 1. Update CheckinHabitIntent
old_intent = """                if targetHabit.frequencyType == "weekly" || targetHabit.frequencyType == "monthly" {
                    if let existing = todays.first { existing.amount += 1; existing.timestamp = today }
                    else { let newCheckin = Checkin(dateString: dateString, amount: 1); modelContainer.mainContext.insert(newCheckin); newCheckin.habit = targetHabit }
                } else {
                    if let existing = todays.first { existing.amount = existing.amount > 0 ? 0 : 1; existing.timestamp = today }
                    else { let newCheckin = Checkin(dateString: dateString, amount: 1); modelContainer.mainContext.insert(newCheckin); newCheckin.habit = targetHabit }
                }"""
new_intent = """                let fillAmount = targetHabit.goalType == "amount" ? targetHabit.amountValue : 1
                if targetHabit.frequencyType == "weekly" || targetHabit.frequencyType == "monthly" {
                    if let existing = todays.first { existing.amount += 1; existing.timestamp = today }
                    else { let newCheckin = Checkin(dateString: dateString, amount: 1); modelContainer.mainContext.insert(newCheckin); newCheckin.habit = targetHabit }
                } else {
                    if let existing = todays.first { existing.amount = existing.amount > 0 ? 0 : fillAmount; existing.timestamp = today }
                    else { let newCheckin = Checkin(dateString: dateString, amount: fillAmount); modelContainer.mainContext.insert(newCheckin); newCheckin.habit = targetHabit }
                }"""
code = code.replace(old_intent, new_intent)


# 2. Update MonthCalendarWidgetView layout
old_month = """        let todayIsDone = isCheckedIn(habit: habit, date: Date(), checkins: checkins)
        
        HStack(spacing: 8) {
            VStack(spacing: 12) {
                Text(monthStr).font(.system(size: 14, weight: .bold)).foregroundColor(Color.primary)
                
                Button(intent: CheckinHabitIntent(habitId: habit.id)) {
                    ZStack {
                        if todayIsDone {
                            Image(systemName: "checkmark.circle.fill").resizable().foregroundColor(.green).frame(width: 44, height: 44)
                        } else {
                            Circle().stroke(Color(hex: habit.color), lineWidth: 2).frame(width: 44, height: 44)
                            Image(systemName: habit.icon).font(.system(size: 20)).foregroundColor(Color(hex: habit.color))
                        }
                    }
                }.buttonStyle(PlainButtonStyle())
                
                Text(habit.name).font(.system(size: 14, weight: .bold)).lineLimit(1).foregroundColor(Color.primary)
            }
            .frame(width: 70)
            
            Spacer(minLength: 0)
            
            VStack(spacing: 2) {
                HStack(spacing: 2) {
                    ForEach(weekdays, id: \\.self) { day in
                        Text(day).font(.system(size: 10, weight: .semibold)).foregroundColor(Color.secondary).frame(width: 18)
                    }
                }
                VStack(spacing: 2) {
                    ForEach(0..<6, id: \\.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0..<7, id: \\.self) { col in
                                let index = row * 7 + col
                                if let dayDate = days[index] {
                                    let isDone = isCheckedIn(habit: habit, date: dayDate, checkins: checkins)
                                    let dayStr = "\\(Calendar.current.component(.day, from: dayDate))"
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(isDone ? Color(hex: habit.color) : Color(UIColor.tertiarySystemFill))
                                            .frame(width: 18, height: 18)
                                        Text(dayStr)
                                            .font(.system(size: 9, weight: isDone ? .bold : .medium))
                                            .foregroundColor(isDone ? .white : Color.primary.opacity(0.8))
                                    }
                                } else {
                                    Color.clear.frame(width: 18, height: 18)
                                }
                            }
                        }
                    }
                }
            }
        }"""
new_month = """        let todayIsDone = isCheckedIn(habit: habit, date: Date(), checkins: checkins)
        
        HStack(spacing: 12) {
            VStack(spacing: 16) {
                Text(monthStr).font(.system(size: 14, weight: .heavy)).foregroundColor(Color.primary).lineLimit(1).minimumScaleFactor(0.8)
                
                Button(intent: CheckinHabitIntent(habitId: habit.id)) {
                    ZStack {
                        if todayIsDone {
                            Image(systemName: "checkmark.circle.fill").resizable().foregroundColor(.green).frame(width: 60, height: 60)
                        } else {
                            Circle().stroke(Color(hex: habit.color), lineWidth: 3).frame(width: 60, height: 60)
                            Image(systemName: habit.icon).font(.system(size: 26)).foregroundColor(Color(hex: habit.color))
                        }
                    }
                }.buttonStyle(PlainButtonStyle())
                
                Text(habit.name).font(.system(size: 16, weight: .bold)).lineLimit(1).foregroundColor(Color.primary)
            }
            .frame(width: 90)
            
            Spacer(minLength: 0)
            
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(weekdays, id: \\.self) { day in
                        Text(day).font(.system(size: 11, weight: .bold)).foregroundColor(Color.secondary).frame(width: 20)
                    }
                }
                VStack(spacing: 4) {
                    ForEach(0..<6, id: \\.self) { row in
                        HStack(spacing: 4) {
                            ForEach(0..<7, id: \\.self) { col in
                                let index = row * 7 + col
                                if let dayDate = days[index] {
                                    let isDone = isCheckedIn(habit: habit, date: dayDate, checkins: checkins)
                                    let dayStr = "\\(Calendar.current.component(.day, from: dayDate))"
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(isDone ? Color(hex: habit.color) : Color(UIColor.tertiarySystemFill))
                                            .frame(width: 20, height: 20)
                                        Text(dayStr)
                                            .font(.system(size: 10, weight: isDone ? .bold : .medium))
                                            .foregroundColor(isDone ? .white : Color.primary.opacity(0.8))
                                    }
                                } else {
                                    Color.clear.frame(width: 20, height: 20)
                                }
                            }
                        }
                    }
                }
            }
        }"""
code = code.replace(old_month, new_month)


# 3. Widget Background / AppTheme injection
app_theme_mod = """
func getWidgetColorScheme(systemScheme: ColorScheme) -> ColorScheme {
    let mode = UserDefaults(suiteName: "group.com.littlehabit.tracker")?.string(forKey: "themeMode") ?? "system"
    if mode == "dark" { return .dark }
    if mode == "light" { return .light }
    return systemScheme
}

struct AppThemeModifier: ViewModifier {
    @Environment(\\.colorScheme) var systemScheme
    func body(content: Content) -> some View {
        let scheme = getWidgetColorScheme(systemScheme: systemScheme)
        content
            .environment(\\.colorScheme, scheme)
    }
}

extension View {
    func forceAppTheme() -> some View {
        self.modifier(AppThemeModifier())
    }
}

struct MyWidgetBackground: View {
    @Environment(\\.colorScheme) var colorScheme
    var body: some View {
        colorScheme == .dark ? Color(hex: "#1C1C1E") : Color(hex: "#F9FAFC")
    }
}
"""

code = re.sub(r'struct MyWidgetBackground: View \{.*?\n\}', app_theme_mod, code, flags=re.DOTALL)

# Inject .forceAppTheme() into all Widget Configurations
code = code.replace('MultiHabitCheckinWidgetView(entry: entry).containerBackground(for: .widget) { MyWidgetBackground() }', 'MultiHabitCheckinWidgetView(entry: entry).forceAppTheme().containerBackground(for: .widget) { MyWidgetBackground().forceAppTheme() }')
code = code.replace('NewSingleHabitWidgetView(entry: entry).containerBackground(for: .widget) { MyWidgetBackground() }', 'NewSingleHabitWidgetView(entry: entry).forceAppTheme().containerBackground(for: .widget) { MyWidgetBackground().forceAppTheme() }')
code = code.replace('VStack { if let habit = habit { MonthCalendarWidgetView(habit: habit, checkins: entry.checkins, date: entry.date) } }.containerBackground(for: .widget) { MyWidgetBackground() }', 'VStack { if let habit = habit { MonthCalendarWidgetView(habit: habit, checkins: entry.checkins, date: entry.date) } }.forceAppTheme().containerBackground(for: .widget) { MyWidgetBackground().forceAppTheme() }')
code = code.replace('MultiHabitWeekWidgetView(entry: entry).containerBackground(for: .widget) { MyWidgetBackground() }', 'MultiHabitWeekWidgetView(entry: entry).forceAppTheme().containerBackground(for: .widget) { MyWidgetBackground().forceAppTheme() }')
code = code.replace('SingleYearlyWidgetView(entry: entry).containerBackground(for: .widget) { MyWidgetBackground() }', 'SingleYearlyWidgetView(entry: entry).forceAppTheme().containerBackground(for: .widget) { MyWidgetBackground().forceAppTheme() }')

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(code)

