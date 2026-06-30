import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Query private var habits: [Habit]
    @Query private var checkins: [Checkin]
    
    @State private var filterMode: String = "month" // month, year, all
    @State private var currentYear: Int = Calendar.current.component(.year, from: Date())
    @State private var currentMonth: Int = Calendar.current.component(.month, from: Date())
    
    // Multi-select Habits filter
    @State private var selectedHabitIds: Set<String> = []
    @State private var showingHabitSelector = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F5F5F7").edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 12) {
                        
                        // Top Filter Section
                        HStack {
                            Button(action: { showingHabitSelector = true }) {
                                HStack(spacing: 4) {
                                    Text(selectedHabitIds.isEmpty ? "全部习惯" : "选择习惯 (\(selectedHabitIds.count))")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.primary)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(20)
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            }
                            
                            Spacer()
                            
                            Picker("Time Range", selection: $filterMode) {
                                Text("全部").tag("all")
                                Text("年").tag("year")
                                Text("月").tag("month")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 160)
                        }
                        .padding(.horizontal)
                        
                        // Selected Habit Tags
                        if !selectedHabitIds.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(selectedHabitIds), id: \.self) { hid in
                                        if let h = habits.first(where: { $0.id == hid }) {
                                            HStack(spacing: 6) {
                                                Circle().fill(Color(hex: h.color)).frame(width: 8, height: 8)
                                                Text(h.name).font(.system(size: 13)).foregroundColor(.primary)
                                                Button(action: {
                                                    selectedHabitIds.remove(hid)
                                                }) {
                                                    Image(systemName: "xmark")
                                                        .font(.system(size: 10, weight: .bold))
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.white)
                                            .cornerRadius(6)
                                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Overview Card
                        VStack(spacing: 16) {
                            HStack {
                                Text(overviewTitle)
                                    .font(.system(size: 16, weight: .semibold))
                                Spacer()
                            }
                            
                            HStack(alignment: .top, spacing: 24) {
                                VStack {
                                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                                        Text("\(uniqueCheckinDays)")
                                            .font(.system(size: 36, weight: .heavy))
                                            .foregroundColor(Color(hex: "#8B5CF6"))
                                        Text("天")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Text("打卡天数")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 100)
                                
                                // Breakdown list
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 12) {
                                        ForEach(breakdownData) { item in
                                            HStack {
                                                Circle()
                                                    .fill(Color(hex: item.colorHex))
                                                    .frame(width: 12, height: 12)
                                                Text(item.name)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                Spacer()
                                                Text(item.amountText)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                            }
                                        }
                                    }
                                }
                                .frame(height: 92)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
                        .padding(.horizontal)
                        
                        // Charts Area
                        VStack {
                            if filterMode == "month" {
                                MonthCalendarView(year: currentYear, month: currentMonth, checkins: scopedCheckins, habits: habits, onPrev: prevMonth, onNext: nextMonth)
                            } else if filterMode == "year" {
                                YearChartView(year: currentYear, chartData: yearlyChartData, onPrev: prevYear, onNext: nextYear, onJump: jumpToMonth)
                            } else {
                                AllChartView(chartData: allChartData, availableYears: availableYears, onJump: jumpToYear)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("打卡统计")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: filterMode) { _, newMode in
                let d = Date()
                if newMode == "month" {
                    currentYear = Calendar.current.component(.year, from: d)
                    currentMonth = Calendar.current.component(.month, from: d)
                } else if newMode == "year" {
                    currentYear = Calendar.current.component(.year, from: d)
                }
            }
            .sheet(isPresented: $showingHabitSelector) {
                HabitSelectorSheet(habits: habits, selectedIds: $selectedHabitIds)
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    // Overview Logic
    private var overviewTitle: String {
        if filterMode == "month" { return "打卡概览 \(currentYear)-\(String(format: "%02d", currentMonth))" }
        if filterMode == "year" { return "打卡概览 \(currentYear)" }
        return "打卡概览 全部"
    }
    
    private var activeHabits: [Habit] {
        if selectedHabitIds.isEmpty { return habits }
        return habits.filter { selectedHabitIds.contains($0.id) }
    }
    
    private var scopedCheckins: [Checkin] {
        if selectedHabitIds.isEmpty { return checkins }
        return checkins.filter { c in
            if let hid = c.habit?.id {
                return selectedHabitIds.contains(hid)
            }
            return false
        }
    }
    
    private var timeFilteredCheckins: [Checkin] {
        return scopedCheckins.filter { c in
            let parts = c.dateString.split(separator: "-")
            guard parts.count == 3 else { return false }
            let cYear = Int(parts[0]) ?? 0
            let cMonth = Int(parts[1]) ?? 0
            
            if filterMode == "month" { return cYear == currentYear && cMonth == currentMonth }
            if filterMode == "year" { return cYear == currentYear }
            return true
        }
    }
    
    private var uniqueCheckinDays: Int {
        let days = Set(timeFilteredCheckins.map { $0.dateString })
        return days.count
    }
    
    struct BreakdownItem: Identifiable {
        let id: String
        let name: String
        let colorHex: String
        let amountText: String
    }
    
    private var breakdownData: [BreakdownItem] {
        var daysMap: [String: Set<String>] = [:]
        var amountMap: [String: Double] = [:]
        
        for c in timeFilteredCheckins {
            if let habitId = c.habit?.id {
                if daysMap[habitId] == nil { daysMap[habitId] = [] }
                daysMap[habitId]?.insert(c.dateString)
                amountMap[habitId, default: 0] += c.amount
            }
        }
        
        return activeHabits.compactMap { h in
            let isAmount = h.goalType == "amount"
            let days = daysMap[h.id]?.count ?? 0
            let amountVal = amountMap[h.id] ?? 0
            
            if days == 0 && amountVal == 0 { return nil }
            
            // Clean up 0.0 trailing decimals
            let amountStr = floor(amountVal) == amountVal ? String(Int(amountVal)) : String(format: "%.1f", amountVal)
            let text = isAmount ? "\(amountStr)\(h.amountUnit)" : "\(days)次"
            return BreakdownItem(id: h.id, name: h.name, colorHex: h.color, amountText: text)
        }
    }
    
    // Chart Logic (Year)
    private var yearlyChartData: [ChartDataPoint] {
        var data: [ChartDataPoint] = []
        for m in 1...12 {
            let monthPrefix = "\(currentYear)-\(String(format: "%02d", m))"
            let monthCheckins = timeFilteredCheckins.filter { $0.dateString.hasPrefix(monthPrefix) }
            
            for h in activeHabits {
                let hCheckins = monthCheckins.filter { $0.habit?.id == h.id }
                let count = Set(hCheckins.map { $0.dateString }).count
                if count > 0 {
                    data.append(ChartDataPoint(xLabel: "\(m)月", group: h.name, value: count, colorHex: h.color))
                }
            }
        }
        return data
    }
    
    // Chart Logic (All)
    private var availableYears: [Int] {
        var years: Set<Int> = [Calendar.current.component(.year, from: Date())]
        for c in scopedCheckins {
            if let y = Int(c.dateString.split(separator: "-").first ?? "0"), y > 0 {
                years.insert(y)
            }
        }
        return Array(years).sorted()
    }
    
    private var allChartData: [ChartDataPoint] {
        var data: [ChartDataPoint] = []
        for y in availableYears {
            let yearPrefix = "\(y)-"
            let yearCheckins = timeFilteredCheckins.filter { $0.dateString.hasPrefix(yearPrefix) }
            
            for h in activeHabits {
                let hCheckins = yearCheckins.filter { $0.habit?.id == h.id }
                let count = Set(hCheckins.map { $0.dateString }).count
                if count > 0 {
                    data.append(ChartDataPoint(xLabel: "\(y)", group: h.name, value: count, colorHex: h.color))
                }
            }
        }
        return data
    }
    
    // Nav Actions
    private func prevMonth() {
        if currentMonth == 1 { currentMonth = 12; currentYear -= 1 } else { currentMonth -= 1 }
    }
    private func nextMonth() {
        if currentMonth == 12 { currentMonth = 1; currentYear += 1 } else { currentMonth += 1 }
    }
    private func prevYear() { currentYear -= 1 }
    private func nextYear() { currentYear += 1 }
    
    private func jumpToMonth(_ m: Int) {
        currentMonth = m
        filterMode = "month"
    }
    private func jumpToYear(_ y: Int) {
        currentYear = y
        filterMode = "year"
    }
}

// Habit Selector Sheet
struct HabitSelectorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let habits: [Habit]
    @Binding var selectedIds: Set<String>
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("选择习惯")
                    .font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(UIColor.systemGray4))
                        .font(.title2)
                }
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 0) {
                    Button(action: { selectedIds.removeAll() }) {
                        HStack {
                            Text("全部习惯").foregroundColor(.primary)
                            Spacer()
                            if selectedIds.isEmpty {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(Color(hex: "#8B5CF6")).font(.title3)
                            } else {
                                Circle().stroke(Color(UIColor.systemGray4), lineWidth: 1).frame(width: 20, height: 20)
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal)
                        .background(Color(UIColor.systemBackground))
                    }
                    Divider().padding(.leading, 16)
                    
                    ForEach(habits) { habit in
                        Button(action: {
                            if selectedIds.contains(habit.id) {
                                selectedIds.remove(habit.id)
                            } else {
                                selectedIds.insert(habit.id)
                            }
                        }) {
                            HStack {
                                Circle().fill(Color(hex: habit.color)).frame(width: 12, height: 12)
                                Text(habit.name).foregroundColor(.primary)
                                Spacer()
                                if selectedIds.contains(habit.id) {
                                    Image(systemName: "checkmark.circle.fill").foregroundColor(Color(hex: "#8B5CF6")).font(.title3)
                                } else {
                                    Circle().stroke(Color(UIColor.systemGray4), lineWidth: 1).frame(width: 20, height: 20)
                                }
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal)
                            .background(Color(UIColor.systemBackground))
                        }
                        Divider().padding(.leading, 40)
                    }
                }
            }
            
            Button(action: { dismiss() }) {
                Text("确认")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(hex: "#8B5CF6"))
                    .cornerRadius(26)
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.bottom))
    }
}

// Chart Models
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let xLabel: String
    let group: String
    let value: Int
    let colorHex: String
}

// Year Bar Chart Component
struct YearChartView: View {
    let year: Int
    let chartData: [ChartDataPoint]
    let onPrev: () -> Void
    let onNext: () -> Void
    let onJump: (Int) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button(action: onPrev) { Image(systemName: "chevron.left").padding() }
                Spacer()
                Text("\(year)年").font(.headline)
                Spacer()
                Button(action: onNext) { Image(systemName: "chevron.right").padding() }
            }
            .foregroundColor(.primary)
            
            if chartData.isEmpty {
                Text("暂无数据").foregroundColor(.secondary).padding(.vertical, 40)
            } else {
                Chart(chartData) { item in
                    BarMark(
                        x: .value("Month", item.xLabel),
                        y: .value("Count", item.value)
                    )
                    .foregroundStyle(Color(hex: item.colorHex))
                }
                .frame(height: 200)
            }
            
            // Quick Jump
            VStack(alignment: .leading, spacing: 12) {
                Text("快速查看月份")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 16)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                    ForEach(1...12, id: \.self) { m in
                        Button(action: { onJump(m) }) {
                            Text("\(m)月")
                                .font(.system(size: 13))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(Color(UIColor.systemGray6))
                                .foregroundColor(.primary)
                                .cornerRadius(6)
                        }
                    }
                }
            }
        }
    }
}

// All Time Bar Chart Component
struct AllChartView: View {
    let chartData: [ChartDataPoint]
    let availableYears: [Int]
    let onJump: (Int) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("所有年份").font(.headline)
                Spacer()
            }
            .padding(.bottom, 8)
            
            if chartData.isEmpty {
                Text("暂无数据").foregroundColor(.secondary).padding(.vertical, 40)
            } else {
                Chart(chartData) { item in
                    BarMark(
                        x: .value("Year", item.xLabel),
                        y: .value("Count", item.value)
                    )
                    .foregroundStyle(Color(hex: item.colorHex))
                }
                .frame(height: 200)
            }
            
            // Quick Jump
            if !availableYears.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("快速查看年份")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 16)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                        ForEach(availableYears, id: \.self) { y in
                            Button(action: { onJump(y) }) {
                                Text("\(y)年")
                                    .font(.system(size: 13))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 6)
                                    .background(Color(UIColor.systemGray6))
                                    .foregroundColor(.primary)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
        }
    }
}

// Calendar Dots Component
struct MonthCalendarView: View {
    let year: Int
    let month: Int
    let checkins: [Checkin]
    let habits: [Habit]
    let onPrev: () -> Void
    let onNext: () -> Void
    
    private let daysInWeek = ["日", "一", "二", "三", "四", "五", "六"]
    
    var body: some View {
        VStack {
            HStack {
                Button(action: onPrev) { Image(systemName: "chevron.left").padding() }
                Spacer()
                Text("\(year)年\(month)月").font(.headline)
                Spacer()
                Button(action: onNext) { Image(systemName: "chevron.right").padding() }
            }
            .foregroundColor(.primary)
            
            HStack {
                ForEach(daysInWeek, id: \.self) { day in
                    Text(day).font(.caption).foregroundColor(.secondary).frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<emptyDaysCount, id: \.self) { _ in
                    Color.clear.frame(height: 48)
                }
                
                ForEach(1...daysInMonth, id: \.self) { day in
                    VStack(spacing: 4) {
                        Text("\(day)")
                            .font(.system(size: 15, weight: isToday(day) ? .bold : .regular))
                            .foregroundColor(isToday(day) ? .white : .primary)
                            .frame(width: 24, height: 24)
                            .background(isToday(day) ? Color(hex: "#8B5CF6") : Color.clear)
                            .clipShape(Circle())
                        
                        // Dots row
                        HStack(spacing: 2) {
                            let dayHabits = habitsForDay(day)
                            // Truncate to max 4 dots to fit UI
                            ForEach(dayHabits.prefix(4)) { h in
                                Circle()
                                    .fill(Color(hex: h.color))
                                    .frame(width: 5, height: 5)
                            }
                            if dayHabits.count > 4 {
                                Circle().fill(Color.gray).frame(width: 3, height: 3)
                            }
                        }
                    }
                    .frame(height: 48)
                }
            }
        }
    }
    
    private var emptyDaysCount: Int {
        var components = DateComponents(year: year, month: month, day: 1)
        let date = Calendar.current.date(from: components)!
        return Calendar.current.component(.weekday, from: date) - 1
    }
    
    private var daysInMonth: Int {
        var components = DateComponents(year: year, month: month)
        let date = Calendar.current.date(from: components)!
        return Calendar.current.range(of: .day, in: .month, for: date)!.count
    }
    
    private func isToday(_ day: Int) -> Bool {
        let d = Date()
        return day == Calendar.current.component(.day, from: d) &&
               month == Calendar.current.component(.month, from: d) &&
               year == Calendar.current.component(.year, from: d)
    }
    
    private func habitsForDay(_ day: Int) -> [Habit] {
        let dateStr = "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))"
        let dayCheckins = checkins.filter { $0.dateString == dateStr }
        let habitIds = Set(dayCheckins.compactMap { $0.habit?.id })
        return habits.filter { habitIds.contains($0.id) }
    }
}
