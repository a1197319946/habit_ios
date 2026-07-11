import re

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    code = f.read()

# Add MyWidgetBackground
bg_struct = """struct MyWidgetBackground: View {
    @Environment(\\.colorScheme) var colorScheme
    var body: some View {
        colorScheme == .dark ? Color(hex: "#1C1C1E") : Color(hex: "#F9FAFC")
    }
}

@main
"""
code = code.replace('@main', bg_struct)

# Replace all Color(UIColor.systemBackground) with MyWidgetBackground()
code = code.replace('Color(UIColor.systemBackground)', 'MyWidgetBackground()')

# Also modify text colors in widgets to adapt
code = code.replace('.foregroundColor(.gray)', '.foregroundColor(Color.secondary)')

old_month = """        HStack(spacing: 8) {
            VStack(spacing: 6) {
                Text(monthStr).font(.system(size: 10, weight: .medium)).foregroundColor(Color.secondary)
                ZStack {
                    Circle().fill(Color(hex: habit.color).opacity(0.15)).frame(width: 36, height: 36)
                    Image(systemName: habit.icon).font(.system(size: 16)).foregroundColor(Color(hex: habit.color))
                }
                Text(habit.name).font(.system(size: 12, weight: .bold)).lineLimit(1)
                Spacer()
            }
            .frame(width: 60)
            Spacer(minLength: 0)
            VStack(spacing: 3) {
                HStack(spacing: 0) {
                    ForEach(weekdays, id: \\.self) { day in
                        Text(day).font(.system(size: 10)).foregroundColor(Color.secondary).frame(maxWidth: .infinity)
                    }
                }
                VStack(spacing: 2) {
                    ForEach(0..<6, id: \\.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<7, id: \\.self) { col in
                                let index = row * 7 + col
                                if let dayDate = days[index] {
                                    let isDone = isCheckedIn(habit: habit, date: dayDate, checkins: checkins)
                                    let dayStr = "\\(Calendar.current.component(.day, from: dayDate))"
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(isDone ? Color(hex: habit.color) : Color(UIColor.tertiarySystemFill))
                                            .frame(width: 14, height: 14)
                                        Text(dayStr)
                                            .font(.system(size: 8, weight: isDone ? .bold : .regular))
                                            .foregroundColor(isDone ? .white : Color.primary.opacity(0.6))
                                    }.frame(maxWidth: .infinity)
                                } else {
                                    Color.clear.frame(width: 14, height: 14).frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                }
            }
        }"""

new_month = """        let todayIsDone = isCheckedIn(habit: habit, date: Date(), checkins: checkins)
        
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
code = code.replace(old_month, new_month)

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'w') as f:
    f.write(code)

