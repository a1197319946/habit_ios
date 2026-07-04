import SwiftUI
import SwiftData

struct HabitEditRoute: Hashable {
    let habit: Habit
}

struct HabitStatsDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appSettings: AppSettings
    @Query private var checkins: [Checkin]
    
    let habit: Habit
    @State private var currentYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showDeleteAlert = false
    @State private var showToast = false
    @State private var toastMessage = ""
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            Color(hex: "#F8F9FA").ignoresSafeArea() // Light background similar to image
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.spacingM) {
                    
                    // Header Card (Icon and Name)
                    HStack(spacing: DS.spacingM) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: habit.color).opacity(0.15))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: habit.icon)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: habit.color))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(habit.name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(DS.onSurface)
                            
                            if habit.goalType == "amount" {
                                Text("目标: \(Int(habit.weeklyTarget))次/周 · \(Int(habit.amountValue))\(habit.amountUnit)")
                                    .font(.system(size: 14))
                                    .foregroundColor(DS.onSurfaceVariant)
                            } else {
                                Text("目标: \(Int(habit.weeklyTarget))次/周")
                                    .font(.system(size: 14))
                                    .foregroundColor(DS.onSurfaceVariant)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
                    
                    // Stats Section
                    VStack(alignment: .leading, spacing: DS.spacingM) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(DS.onSurfaceVariant)
                            Text("统计数据")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(DS.onSurface)
                            Spacer()
                        }
                        
                        let yearCheckins = getCheckinsForYear()
                        let completedDays = Set(yearCheckins.map { $0.dateString }).count
                        let totalAmount = yearCheckins.reduce(0) { $0 + $1.amount }
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DS.spacingM) {
                            statBox(icon: "checkmark.circle.fill", iconColor: Color(hex: "#FF8C8C"), value: "\(completedDays)", unit: "天", label: "打卡天数")
                            if habit.goalType == "amount" {
                                statBox(icon: "number.circle.fill", iconColor: Color.yellow, value: "\(Int(totalAmount))", unit: habit.amountUnit, label: "总数值")
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
                    
                    // Calendar Section
                    VStack(alignment: .leading, spacing: DS.spacingM) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(DS.onSurfaceVariant)
                            Text("年度日历")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(DS.onSurface)
                        }
                        
                        HStack {
                            Button(action: { withAnimation { currentYear -= 1 } }) {
                                Image(systemName: "chevron.left")
                                    .padding(8)
                            }
                            .background(Color(hex: "#F3F4F6"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .foregroundColor(DS.onSurface)
                            
                            Text("\(currentYear) 年")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(DS.onSurface)
                                .padding(.horizontal, 8)
                            
                            Button(action: { withAnimation { currentYear += 1 } }) {
                                Image(systemName: "chevron.right")
                                    .padding(8)
                            }
                            .background(Color(hex: "#F3F4F6"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .foregroundColor(DS.onSurface)
                            
                            Spacer()
                        }
                        
                        // Empty space instead of Legend
                        Spacer().frame(height: 8)
                        
                        // Yearly Grid
                        let months = Array(1...12)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: DS.spacingL) {
                            ForEach(months, id: \.self) { month in
                                NavigationLink(value: HabitMonthRoute(habit: habit, year: currentYear, month: month)) {
                                    MonthMiniGrid(year: currentYear, month: month, checkins: getCheckinsForYear(), habit: habit)
                                        .padding(8)
                                        .background(Color.black.opacity(0.02))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(DS.spacingL)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
                    
                    Spacer().frame(height: 40)
                }
                .padding(DS.spacingM)
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
        .navigationTitle("习惯详情")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color(hex: "#F8F9FA"), for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DS.onSurface)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 4)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    NavigationLink(value: HabitEditRoute(habit: habit)) {
                        Label("编辑", systemImage: "pencil")
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
                                try? modelContext.save()
                                dismiss()
                            }
                        }
                    }) {
                        Label(habit.isArchived ? "恢复" : "归档", systemImage: habit.isArchived ? "tray.and.arrow.up" : "archivebox")
                    }
                    Button(role: .destructive, action: {
                        showDeleteAlert = true
                    }) {
                        Label("删除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DS.onSurface)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 4)
                }
            }
        }
        .alert("确认删除?", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                modelContext.delete(habit)
                dismiss()
            }
        } message: {
            Text("删除后所有相关打卡数据将无法恢复。")
        }
    }
    
    private func getCheckinsForYear() -> [Checkin] {
        let prefix = "\(currentYear)-"
        return checkins.filter { $0.habit?.id == habit.id && $0.dateString.hasPrefix(prefix) }
    }
    
    private func statBox(icon: String, iconColor: Color, value: String, unit: String, label: String) -> some View {
        HStack(spacing: DS.spacingM) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(DS.onSurface)
                    Text(unit)
                        .font(.system(size: 12))
                        .foregroundColor(DS.onSurfaceVariant)
                }
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(DS.onSurfaceVariant)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            Spacer()
        }
        .padding(DS.spacingM)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#F3F4F6"), lineWidth: 1))
    }
    

}

struct MonthMiniGrid: View {
    let year: Int
    let month: Int
    let checkins: [Checkin]
    let habit: Habit
    
    @EnvironmentObject private var appSettings: AppSettings
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(month)月")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(DS.onSurface)
            
            let daysInMonth = calendar.range(of: .day, in: .month, for: dateForFirstDayOfMonth())?.count ?? 30
            let firstWeekday = getFirstWeekday()
            let rows = 6 // Force 6 rows so that the grids are perfectly aligned vertically
            
            VStack(spacing: 3) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 3) {
                        ForEach(0..<7, id: \.self) { col in
                            let index = row * 7 + col
                            let day = index - firstWeekday + 1
                            
                            if day > 0 && day <= daysInMonth {
                                let dateStr = String(format: "%04d-%02d-%02d", year, month, day)
                                let isCompleted = checkins.contains(where: { $0.dateString == dateStr })
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(isCompleted ? Color(hex: "#FF8C8C") : Color(hex: "#F3F4F6"))
                                    .frame(width: 9, height: 9)
                            } else {
                                Color.clear
                                    .frame(width: 9, height: 9)
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
        return wd - 1 // 0 for Sunday
    }
}
