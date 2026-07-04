import SwiftUI
import SwiftData

struct HabitMonthRoute: Hashable {
    let habit: Habit
    let year: Int
    let month: Int
}

struct HabitMonthDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appSettings: AppSettings
    @Query private var checkins: [Checkin]
    @Query private var moodRecords: [MoodRecord]
    
    let habit: Habit
    @State var year: Int
    @State var month: Int
    
    @State private var currentMonthDate: Date
    private let calendar = Calendar.current
    
    init(habit: Habit, year: Int, month: Int) {
        self.habit = habit
        self._year = State(initialValue: year)
        self._month = State(initialValue: month)
        var comp = DateComponents()
        comp.year = year
        comp.month = month
        comp.day = 1
        self._currentMonthDate = State(initialValue: Calendar.current.date(from: comp) ?? Date())
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#F8F9FA").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.spacingM) {
                    
                    // Month Grid Card (Reused from StatisticsView)
                    MonthGridCard(
                        habits: [habit],
                        checkins: checkins.filter { $0.habit?.id == habit.id },
                        appSettings: appSettings,
                        currentMonthDate: $currentMonthDate
                    )
                    
                    // Stats Summary Card
                    let currentMonthCheckins = checkinsForCurrentMonth()
                    let completedDaysCount = Set(currentMonthCheckins.map { $0.dateString }).count
                    let totalAmount = currentMonthCheckins.reduce(0) { $0 + $1.amount }
                    
                    HStack(spacing: 12) {
                        // Days card
                        VStack(spacing: 4) {
                            Text("\(completedDaysCount)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(DS.onSurface)
                            Text("打卡天数")
                                .font(.system(size: 12))
                                .foregroundColor(DS.onSurfaceVariant)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.7))
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
                        
                        // Total card
                        if habit.goalType == "amount" {
                            VStack(spacing: 4) {
                                Text("\(String(format: "%.1f", totalAmount).replacingOccurrences(of: ".0", with: ""))")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(DS.onSurface)
                                Text("打卡数量")
                                    .font(.system(size: 12))
                                    .foregroundColor(DS.onSurfaceVariant)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.7))
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1))
                            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Timeline Records
                    VStack(alignment: .leading, spacing: DS.spacingL) {
                        HStack {
                            Text("打卡记录")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(DS.onSurface)
                            Spacer()
                        }
                        
                        if currentMonthCheckins.isEmpty {
                            Text("暂无打卡记录")
                                .font(.system(size: 14))
                                .foregroundColor(DS.onSurfaceVariant)
                        } else {
                            // Sort descending
                            let sortedCheckins = currentMonthCheckins.sorted(by: { $0.timestamp > $1.timestamp })
                            
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(Array(sortedCheckins.enumerated()), id: \.element.id) { index, checkin in
                                    timelineItem(checkin: checkin, isLast: index == sortedCheckins.count - 1)
                                }
                            }
                        }
                    }
                    .padding(.vertical, DS.spacingM)
                    .padding(.horizontal, 16)
                    
                    Spacer().frame(height: 40)
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("\(String(format: "%04d", year))年 \(String(format: "%02d", month))月 ｜ \(habit.name)")
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
                        .background(Color.clear)
                        .clipShape(Circle())
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 8) {
                    Button(action: { 
                        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonthDate) {
                            currentMonthDate = newDate
                        }
                    }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(DS.surfaceContainerLow)
                            .overlay(Image(systemName: "chevron.left").font(.system(size: 10, weight: .bold)).foregroundColor(DS.onSurfaceVariant))
                    }
                    Button(action: { 
                        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonthDate) {
                            currentMonthDate = newDate
                        }
                    }) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(DS.surfaceContainerLow)
                            .overlay(Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold)).foregroundColor(DS.onSurfaceVariant))
                    }
                }
            }
        }
        .onChange(of: currentMonthDate) { _, newValue in
            year = calendar.component(.year, from: newValue)
            month = calendar.component(.month, from: newValue)
        }
    }
    
    private func checkinsForCurrentMonth() -> [Checkin] {
        let prefix = String(format: "%04d-%02d-", year, month)
        return checkins.filter { $0.habit?.id == habit.id && $0.dateString.hasPrefix(prefix) }
    }
    
    private func getMoodForDate(_ dateStr: String) -> MoodRecord? {
        // Find a mood record for this habit on this date
        return moodRecords.first { $0.habit?.id == habit.id && formattedDateString($0.timestamp) == dateStr }
    }
    
    private func formattedDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(DS.onSurface)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(DS.onSurfaceVariant)
        }
    }
    
    private func emoji(for type: String) -> String {
        switch type {
        case "excited": return "🤩"
        case "happy": return "😊"
        case "normal": return "😐"
        case "down": return "😔"
        case "angry": return "😡"
        default: return "✨"
        }
    }
    
    @ViewBuilder
    private func timelineItem(checkin: Checkin, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 0) {
            // Timeline Node
            ZStack(alignment: .top) {
                if !isLast {
                    Rectangle()
                        .fill(Color(hex: habit.color).opacity(0.2))
                        .frame(width: 2)
                        .padding(.top, 24)
                }
                
                Circle()
                    .fill(Color(hex: habit.color).opacity(0.15))
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(Color(hex: habit.color), lineWidth: 2))
                    .padding(.top, 4)
            }
            .frame(width: 32)
            
            // Content Card
            VStack(alignment: .leading, spacing: 12) {
                // Header (Date and Time)
                HStack(alignment: .center) {
                    Text(formattedDisplayDate(checkin.timestamp))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(DS.onSurface)
                    
                    Spacer()
                    
                    if habit.goalType == "amount" && checkin.amount > 0 {
                        Text("+\(String(format: "%.1f", checkin.amount).replacingOccurrences(of: ".0", with: "")) \(habit.amountUnit)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: habit.color))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: habit.color).opacity(0.1))
                            .clipShape(Capsule())
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: habit.color))
                            .font(.system(size: 16))
                    }
                }
                
                // Mood Log (if exists)
                if let mood = getMoodForDate(checkin.dateString) {
                    HStack(alignment: .top, spacing: 10) {
                        Text(emoji(for: mood.type))
                            .font(.system(size: 20))
                            
                        if !mood.text.isEmpty {
                            Text(mood.text)
                                .font(.system(size: 13))
                                .foregroundColor(DS.onSurfaceVariant)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(Color.black.opacity(0.02))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
            .padding(.bottom, isLast ? 0 : 16)
            .padding(.leading, 8)
        }
    }
    
    private func formattedDisplayDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
}
