import SwiftUI
import WidgetKit
import CoreData
import Charts

struct HabitEditRoute: Hashable {
    let habit: Habit
}

struct MonthlyTrendDataPoint: Identifiable {
    let id = UUID()
    let monthLabel: String
    let daysCount: Int
    let totalAmount: Double
}

struct HabitStatsDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var appSettings: AppSettings
    @FetchRequest(sortDescriptors: []) private var checkins: FetchedResults<Checkin>
    
    @ObservedObject var habit: Habit
    @State private var currentYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showDeleteAlert = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var showingEditSheet = false
    
    private var calendar: Calendar { appSettings.customCalendar }
    
    private var monthlyTrendData: [MonthlyTrendDataPoint] {
        var points: [MonthlyTrendDataPoint] = []
        let yearCheckins = getCheckinsForYear()
        let now = Date()
        let thisYear = calendar.component(.year, from: now)
        let maxMonth: Int
        if currentYear < thisYear {
            maxMonth = 12
        } else if currentYear == thisYear {
            maxMonth = calendar.component(.month, from: now)
        } else {
            maxMonth = 0
        }
        guard maxMonth >= 1 else { return points }
        
        for m in 1...maxMonth {
            let prefix = String(format: "%04d-%02d", currentYear, m)
            let mChecks = yearCheckins.filter { $0.dateString.hasPrefix(prefix) }
            let days = Set(mChecks.map { $0.dateString }).count
            let amount = mChecks.reduce(0.0) { $0 + $1.amount }
            let dateForLabel = Calendar.current.date(from: DateComponents(year: currentYear, month: m)) ?? Date()
            let df = DateFormatter()
            df.locale = Locale(identifier: appSettings.resolvedLanguage.localeIdentifier)
            df.setLocalizedDateFormatFromTemplate("MMM")
            let label = df.string(from: dateForLabel)
            points.append(MonthlyTrendDataPoint(monthLabel: label, daysCount: days, totalAmount: amount))
        }
        return points
    }
    
    @ViewBuilder
    private var headerCard: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(DS.primary.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: habit.icon)
                    .font(.system(size: 16))
                    .foregroundColor(DS.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(DS.onSurface)
                
                if habit.goalType == "amount" {
                    let periodStr = habit.frequencyType == "weekly" ? L10n.week2.tr(appSettings.resolvedLanguage) : L10n.month3.tr(appSettings.resolvedLanguage)
                    let amtStr = String(format: "%.1f", habit.amountValue).replacingOccurrences(of: ".0", with: "")
                    Text("\(L10n.target.tr(appSettings.resolvedLanguage)) \(amtStr) \((habit.amountUnit ?? "次").tr(appSettings.resolvedLanguage)) / \(periodStr)")
                        .font(.system(size: 13))
                        .foregroundColor(DS.onSurfaceVariant)
                } else {
                    let target = habit.frequencyType == "weekly" ? habit.weeklyTarget : habit.monthlyTarget
                    let periodStr = habit.frequencyType == "weekly" ? L10n.week2.tr(appSettings.resolvedLanguage) : L10n.month3.tr(appSettings.resolvedLanguage)
                    Text("\(L10n.target.tr(appSettings.resolvedLanguage)) \(target) \(L10n.times1.tr(appSettings.resolvedLanguage)) / \(periodStr)")
                        .font(.system(size: 13))
                        .foregroundColor(DS.onSurfaceVariant)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(DS.surface.opacity(0.8))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
    }

    @ViewBuilder
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text(L10n.statistics.tr(appSettings.resolvedLanguage))
                    .foregroundColor(DS.onSurface)
            } icon: {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(DS.primary)
            }
            .font(.system(size: 16, weight: .bold))
            
            Spacer()
            
            let yearCheckins = getCheckinsForYear()
            let completedDays = Set(yearCheckins.map { $0.dateString }).count
            let totalAmount = yearCheckins.reduce(0) { $0 + $1.amount }
            
            if habit.goalType == "amount" {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    statBox(icon: "checkmark.circle.fill", iconColor: Color(hex: habit.color), value: "\(completedDays)", unit: L10n.days.tr(appSettings.resolvedLanguage), label: L10n.checkInDays.tr(appSettings.resolvedLanguage))
                    statBox(icon: "number.circle.fill", iconColor: Color.yellow, value: "\(Int(totalAmount))", unit: (habit.amountUnit ?? "").tr(appSettings.resolvedLanguage), label: L10n.totalAmount1.tr(appSettings.resolvedLanguage))
                }
            } else {
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 10) {
                    statBox(icon: "checkmark.circle.fill", iconColor: Color(hex: habit.color), value: "\(completedDays)", unit: L10n.days.tr(appSettings.resolvedLanguage), label: L10n.checkInDays.tr(appSettings.resolvedLanguage))
                }
            }
        }
        .padding(16)
        .background(DS.surface.opacity(0.8))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(DS.outline, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
    }

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    
                    headerCard
                    
                    statsSection
                    
                    // Unified Yearly Calendar and Monthly Trend/Details Card
                    yearlyCalendarSection
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            
            if showToast {
                VStack {
                    Spacer()
                    Text(toastMessage)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.black.opacity(0.8))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                        .padding(.bottom, 60)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(100)
            }
        }
        .background(AmbientBackground())
        .navigationTitle(L10n.habitDetails.tr(appSettings.resolvedLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEditSheet = true }) {
                        Label(L10n.edit.tr(appSettings.resolvedLanguage), systemImage: "pencil")
                    }
                    Button(action: {
                        let isArchiving = !habit.isArchived
                        toastMessage = isArchiving ? "归档成功" : "已恢复"
                        withAnimation(.spring()) {
                            showToast = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.spring()) {
                                showToast = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                let h = habit
                                h.isArchived.toggle()
                                if h.isArchived {
                                    NotificationManager.shared.cancelReminder(for: h)
                                } else {
                                    NotificationManager.shared.scheduleReminder(for: h)
                                }
                                try? viewContext.save()
        WidgetCenter.shared.reloadAllTimelines()
                                dismiss()
                            }
                        }
                    }) {
                        Label(habit.isArchived ? L10n.restore1.tr(appSettings.resolvedLanguage) : L10n.archive.tr(appSettings.resolvedLanguage), systemImage: habit.isArchived ? "tray.and.arrow.up" : "archivebox")
                    }
                    Button(role: .destructive, action: {
                        showDeleteAlert = true
                    }) {
                        Label(L10n.delete.tr(appSettings.resolvedLanguage), systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DS.primary)
                        .padding(8)
                        .background(DS.surface)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 4)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            HabitDetailView(habit: habit)
        }
        .alert(L10n.deleteHabit.tr(appSettings.resolvedLanguage), isPresented: $showDeleteAlert) {
            Button(L10n.cancel.tr(appSettings.resolvedLanguage), role: .cancel) { }
            Button(L10n.delete.tr(appSettings.resolvedLanguage), role: .destructive) {
                NotificationManager.shared.cancelReminder(for: habit)
                if let checkins = habit.checkins as? Set<Checkin> {
                    for c in checkins { viewContext.delete(c) }
                }
                if let moods = habit.moodRecords as? Set<MoodRecord> {
                    for m in moods { viewContext.delete(m) }
                }
                viewContext.delete(habit)
                try? viewContext.save()
                WidgetCenter.shared.reloadAllTimelines()
                dismiss()
            }
        } message: {
            Text(L10n.dataIrrecoverableAfterDeletion.tr(appSettings.resolvedLanguage))
        }
    }
    
    private func getCheckinsForYear() -> [Checkin] {
        let prefix = "\(currentYear)-"
        return checkins.filter { $0.habit?.id == habit.id && $0.dateString.hasPrefix(prefix) }
    }
    
    private func statBox(icon: String, iconColor: Color, value: String, unit: String, label: String) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                (Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(DS.onSurface)
                + Text(unit.isEmpty ? "" : " \(unit)")
                    .font(.system(size: 12))
                    .foregroundColor(DS.onSurfaceVariant))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(DS.onSurfaceVariant)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            Spacer()
        }
        .padding(12)
        .background(DS.surface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(DS.uncheckedPlaceholder, lineWidth: 1))
    }
    
    @ViewBuilder
    private var yearlyCalendarSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text(L10n.yearlyCalendar.tr(appSettings.resolvedLanguage))
                    .foregroundColor(DS.onSurface)
            } icon: {
                Image(systemName: "calendar")
                    .foregroundColor(DS.primary)
            }
            .font(.system(size: 16, weight: .bold))
            
            // Year Selector
            HStack {
                Button(action: { withAnimation { currentYear -= 1 } }) {
                    Image(systemName: "chevron.left")
                        .padding(8)
                }
                .background(DS.uncheckedPlaceholder)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .foregroundColor(DS.onSurface)
                
                Text("\(String(currentYear))\(L10n.year.tr(appSettings.resolvedLanguage))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DS.onSurface)
                    .padding(.horizontal, 8)
                
                Button(action: { withAnimation { currentYear += 1 } }) {
                    Image(systemName: "chevron.right")
                        .padding(8)
                }
                .background(DS.uncheckedPlaceholder)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .foregroundColor(DS.onSurface)
                
                Spacer()
            }
            
            // Sub-header 1: Monthly Trend (`月度趋势`)
            HStack {
                Text(L10n.monthlyTrend.tr(appSettings.resolvedLanguage))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(DS.onSurfaceVariant)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(DS.uncheckedPlaceholder)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Spacer()
            }
            .padding(.top, 4)
            
            let trendData = monthlyTrendData
            let isAmount = habit.goalType == "amount"
            
            if !trendData.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Chart(trendData) { point in
                        let yValue = isAmount ? point.totalAmount : Double(point.daysCount)
                        AreaMark(
                            x: .value("Month", point.monthLabel),
                            y: .value("Value", yValue)
                        )
                        .foregroundStyle(LinearGradient(colors: [Color(hex: habit.color).opacity(0.4), Color(hex: habit.color).opacity(0.05)], startPoint: .top, endPoint: .bottom))
                        .interpolationMethod(.catmullRom)
                        
                        LineMark(
                            x: .value("Month", point.monthLabel),
                            y: .value("Value", yValue)
                        )
                        .foregroundStyle(Color(hex: habit.color))
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Month", point.monthLabel),
                            y: .value("Value", yValue)
                        )
                        .foregroundStyle(Color(hex: habit.color))
                    }
                    .chartLegend(.hidden)
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel()
                                .foregroundStyle(DS.onSurfaceVariant)
                                .font(.system(size: 11, weight: .medium))
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4]))
                                .foregroundStyle(DS.outlineVariant.opacity(0.5))
                            AxisValueLabel()
                                .foregroundStyle(DS.onSurfaceVariant)
                                .font(.system(size: 11, weight: .medium))
                        }
                    }
                    .frame(height: 160)
                }
            } else {
                Text(L10n.noData.tr(appSettings.resolvedLanguage))
                    .font(.system(size: 13))
                    .foregroundColor(DS.onSurfaceVariant)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 80)
            }
            
            // Sub-header 2: Monthly Details (`月度详情`)
            HStack {
                Text(L10n.monthlyDetails.tr(appSettings.resolvedLanguage))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(DS.onSurfaceVariant)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(DS.uncheckedPlaceholder)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Spacer()
            }
            .padding(.top, 10)
            
            // Yearly Grid (3 columns for compact, adaptive layout)
            let months = Array(1...12)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)], spacing: 10) {
                ForEach(months, id: \.self) { month in
                    NavigationLink(value: HabitMonthRoute(habit: habit, year: currentYear, month: month)) {
                        MonthMiniGrid(year: currentYear, month: month, checkins: getCheckinsForYear(), habit: habit)
                            .padding(8)
                            .background(DS.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(DS.outlineVariant, lineWidth: 1))
                            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(16)
        .background(DS.surface.opacity(0.8))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(DS.outline, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
    }
}

struct MonthMiniGrid: View {
    let year: Int
    let month: Int
    let checkins: [Checkin]
    @ObservedObject var habit: Habit
    
    @EnvironmentObject private var appSettings: AppSettings
    private var calendar: Calendar { appSettings.customCalendar }
    
    private var monthName: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: appSettings.resolvedLanguage.localeIdentifier)
        df.setLocalizedDateFormatFromTemplate("MMM")
        return df.string(from: dateForFirstDayOfMonth())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(monthName)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(DS.onSurface)
            
            let daysInMonth = calendar.range(of: .day, in: .month, for: dateForFirstDayOfMonth())?.count ?? 30
            let firstWeekday = getFirstWeekday()
            let rows = 6 // Force 6 rows so that the grids are perfectly aligned vertically
            
            VStack(spacing: 2.5) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 2.5) {
                        ForEach(0..<7, id: \.self) { col in
                            let index = row * 7 + col
                            let day = index - firstWeekday + 1
                            
                            if day > 0 && day <= daysInMonth {
                                let dateStr = String(format: "%04d-%02d-%02d", year, month, day)
                                let isCompleted = checkins.contains(where: { $0.dateString == dateStr })
                                RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                                    .fill(isCompleted ? Color(hex: habit.color) : DS.uncheckedPlaceholder.opacity(0.6))
                                    .frame(width: 10.5, height: 10.5)
                            } else {
                                Color.clear
                                    .frame(width: 10.5, height: 10.5)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func dateForFirstDayOfMonth() -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        return calendar.date(from: components) ?? Date()
    }
    
    private func getFirstWeekday() -> Int {
        let date = dateForFirstDayOfMonth()
        let wd = calendar.component(.weekday, from: date)
        let first = appSettings.firstWeekday
        var offset = wd - first
        if offset < 0 { offset += 7 }
        return offset
    }
}
