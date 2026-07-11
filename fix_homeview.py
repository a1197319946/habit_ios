with open('Sources/HomeView.swift', 'r') as f:
    code = f.read()

# 1. WeeklySlider onChange
old_slider = """        .scrollPosition(id: $weekOffset)
        .frame(height: 90)"""
new_slider = """        .scrollPosition(id: $weekOffset)
        .frame(height: 90)
        .onChange(of: weekOffset) { newOffset in
            if let newOffset = newOffset {
                let targetDate = calendar.date(byAdding: .weekOfYear, value: newOffset, to: Date()) ?? Date()
                if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: targetDate) {
                    let todayWeekday = calendar.component(.weekday, from: Date())
                    var matchedDate = weekInterval.start
                    for i in 0..<7 {
                        if let d = calendar.date(byAdding: .day, value: i, to: weekInterval.start),
                           calendar.component(.weekday, from: d) == todayWeekday {
                            matchedDate = d
                            break
                        }
                    }
                    selectedDate = matchedDate
                }
            }
        }"""
code = code.replace(old_slider, new_slider)

# 2. Today text
old_day_text = """                        Text(dayStr.tr(appSettings.resolvedLanguage))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(isSelected ? .white : DS.onSurfaceVariant)"""
new_day_text = """                        Text(isToday ? "Today".tr(appSettings.resolvedLanguage) : dayStr.tr(appSettings.resolvedLanguage))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(isSelected ? .white : (isToday ? DS.primary : DS.onSurfaceVariant))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)"""
code = code.replace(old_day_text, new_day_text)

# 3. onAppear reset
old_appear = """        .background(AmbientBackground())
        // Overlays & Sheets"""
new_appear = """        .background(AmbientBackground())
        .onAppear {
            selectedDate = Date()
            weekOffset = 0
        }
        // Overlays & Sheets"""
code = code.replace(old_appear, new_appear)


with open('Sources/HomeView.swift', 'w') as f:
    f.write(code)

