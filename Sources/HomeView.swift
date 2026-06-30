import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.order) private var habits: [Habit]
    @Query private var checkins: [Checkin]
    
    @State private var selectedDate: Date = Date()
    @State private var icloudEnabled: Bool = true
    
    // UI State
    @State private var showingAmountSheet = false
    @State private var showingMoodSheet = false
    @State private var showingSuccessModal = false
    @State private var showingMakeupAlert = false
    @State private var showHabitActionSheet = false
    
    @State private var selectedHabit: Habit?
    @State private var initialAmountForSheet: Double?
    
    // Confetti
    @State private var showConfetti = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F5F5F7").edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        // Header Section with Image
                        ZStack(alignment: .bottom) {
                            ZStack(alignment: .topLeading) {
                                Image("header_bg")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .edgesIgnoringSafeArea(.top)
                                // Logo
                                HStack(spacing: 8) {
                                    Image("app_logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .clipShape(Circle())
                                    
                                    Text("小习惯")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color(hex: "#1F2937"))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
                                .padding(.leading, 20)
                                .padding(.top, 56) // Account for safe area
                            }
                            
                            HStack {
                                Spacer()
                                // Hero Illustration Badge
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white)
                                        .frame(width: 72, height: 72)
                                        .shadow(color: Color(hex: "#6366F1").opacity(0.1), radius: 12, y: 5)
                                    
                                    VStack(spacing: 0) {
                                        Rectangle()
                                            .fill(Color(hex: "#EF4444"))
                                            .frame(height: 20)
                                            .clipShape(CustomTopCorners(radius: 20))
                                        Spacer()
                                    }
                                    .frame(width: 72, height: 72)
                                    
                                    VStack(spacing: 2) {
                                        Spacer().frame(height: 16)
                                        Text("\(Calendar.current.component(.month, from: Date()))")
                                            .font(.system(size: 32, weight: .heavy))
                                            .foregroundColor(Color(UIColor.darkText))
                                        Text("月")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .frame(width: 72, height: 72)
                                    
                                    // Check badge
                                    Circle()
                                        .fill(Color(hex: "#10B981"))
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                        .offset(x: 28, y: 28)
                                }
                                .rotationEffect(Angle(degrees: 4))
                                .padding(.trailing, 28)
                                .offset(y: -40)
                            }
                        }
                        
                        // iCloud Banner
                        if !icloudEnabled {
                            HStack {
                                Image(systemName: "info.circle.fill").foregroundColor(Color(hex: "#EF4444"))
                                Text("未开启 iCloud，数据将无法跨设备同步")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(hex: "#B91C1C"))
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(hex: "#FEF2F2"))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#FCA5A5"), lineWidth: 1))
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .zIndex(10)
                        }
                        
                        // Calendar
                        WeeklyCalendarView(selectedDate: $selectedDate, checkins: checkins)
                            .frame(height: 100)
                            .padding(.top, 8)
                        
                        // Habits Header
                        HStack {
                            Spacer()
                            NavigationLink(destination: HabitListView()) {
                                HStack(spacing: 4) {
                                    Text("管理习惯")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        
                        // Habits Grid
                        if habits.isEmpty {
                            VStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.white.opacity(0.8))
                                        .frame(width: 80, height: 80)
                                    Image(systemName: "flag.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color(hex: "#8B5CF6"))
                                }
                                Text("这里空空如也")
                                    .foregroundColor(.secondary)
                                
                                NavigationLink(destination: HabitDetailView(habit: nil)) {
                                    Text("创建第一个习惯")
                                        .font(.subheadline)
                                        .foregroundColor(Color(hex: "#8B5CF6"))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color(hex: "#8B5CF6").opacity(0.1))
                                        .cornerRadius(20)
                                }
                            }
                            .padding(.top, 40)
                        } else {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                                ForEach(habits) { habit in
                                    HabitCard(habit: habit, selectedDate: selectedDate, checkins: checkins) {
                                        handleCheckinTap(habit: habit)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 16)
                        }
                        
                        // Bottom quote banner
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(colors: [Color(hex: "#8B5CF6").opacity(0.8), Color(hex: "#C4B5FD")], startPoint: .leading, endPoint: .trailing))
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("每天坚持一点点")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("今天也要加油哦！💪")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                Spacer()
                                Text("⭐").font(.title)
                            }
                            .padding()
                        }
                        .frame(height: 70)
                        .padding(.horizontal)
                        .padding(.top, 30)
                        .padding(.bottom, 40)
                        
                    }
                }
                
                // Confetti overlay
                if showConfetti {
                    ConfettiView()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSuccessModal) {
                if let selectedHabit = selectedHabit {
                    CheckinSuccessView(
                        habit: selectedHabit,
                        date: selectedDate,
                        checkins: checkins,
                        onRecordMood: {
                            showingMoodSheet = true
                        }
                    )
                    .presentationDetents([.fraction(0.65)])
                    .presentationDragIndicator(.visible)
                }
            }
            .alert("提示", isPresented: $showingMakeupAlert) {
                Button("取消", role: .cancel) { }
                Button("确认") {
                    if let h = selectedHabit {
                        executeCheckin(habit: h)
                    }
                }
            } message: {
                Text("对 \(formatDate(selectedDate)) 补卡？")
            }
            .confirmationDialog("管理打卡", isPresented: $showHabitActionSheet, titleVisibility: .hidden) {
                if let habit = selectedHabit {
                    if let existing = checkins.first(where: { $0.habit?.id == habit.id && $0.dateString == formatDate(selectedDate) }) {
                        if habit.goalType == "amount" {
                            Button("修改数据") {
                                initialAmountForSheet = existing.amount
                                showingAmountSheet = true
                            }
                        }
                        Button("撤销打卡", role: .destructive) {
                            modelContext.delete(existing)
                        }
                    } else {
                        Button("打卡") {
                            processCheckin()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAmountSheet) {
                if let habit = selectedHabit {
                    AmountCheckinSheet(habit: habit, selectedDate: selectedDate, initialAmount: initialAmountForSheet) {
                        showingAmountSheet = false
                        if initialAmountForSheet == nil {
                            triggerSuccessSequence()
                        }
                    }
                    .presentationDetents([.fraction(0.6)])
                }
            }
            .sheet(isPresented: $showingMoodSheet) {
                if let habit = selectedHabit {
                    MoodRecorderView(habit: habit)
                        .presentationDetents([.medium, .large])
                }
            }
        }
    }
    
    private func handleCheckinTap(habit: Habit) {
        let dateString = formatDate(selectedDate)
        let todayString = formatDate(Date())
        
        // Prevent future
        if selectedDate > Date() && dateString != todayString {
            // Future checkin blocked
            return
        }
        
        selectedHabit = habit
        
        if checkins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateString }) {
            // Already checked in, show action sheet
            showHabitActionSheet = true
        } else {
            // Not checked in, check for makeup logic directly without action sheet
            processCheckin()
        }
    }
    
    private func processCheckin() {
        let dateString = formatDate(selectedDate)
        let todayString = formatDate(Date())
        guard let habit = selectedHabit else { return }
        
        if dateString != todayString && selectedDate < Date() {
            showingMakeupAlert = true
        } else {
            executeCheckin(habit: habit)
        }
    }
    
    private func executeCheckin(habit: Habit) {
        if habit.goalType == "amount" {
            initialAmountForSheet = nil
            showingAmountSheet = true
        } else {
            let newCheckin = Checkin(dateString: formatDate(selectedDate), amount: 1)
            newCheckin.habit = habit
            modelContext.insert(newCheckin)
            triggerSuccessSequence()
        }
    }
    
    private func triggerSuccessSequence() {
        showConfetti = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showConfetti = false
            showingSuccessModal = true
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// Additional Components (DayCell, WeeklyCalendarView, HabitCard, AmountCheckinSheet, ConfettiView)

struct WeeklyCalendarView: View {
    @Binding var selectedDate: Date
    var checkins: [Checkin]
    
    @State private var weeks: [[Date]] = []
    @State private var currentWeekIndex: Int = 1
    
    init(selectedDate: Binding<Date>, checkins: [Checkin]) {
        self._selectedDate = selectedDate
        self.checkins = checkins
    }
    
    var body: some View {
        TabView(selection: $currentWeekIndex) {
            ForEach(0..<weeks.count, id: \.self) { index in
                HStack(spacing: 0) {
                    ForEach(weeks[index], id: \.self) { date in
                        DayCell(date: date, selectedDate: selectedDate, checkins: checkins)
                            .onTapGesture {
                                withAnimation {
                                    selectedDate = date
                                }
                            }
                    }
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onAppear { setupWeeks() }
        .onChange(of: currentWeekIndex) { _, newIndex in
            if newIndex == 0 { shiftWeeks(by: -1) }
            else if newIndex == 2 { shiftWeeks(by: 1) }
        }
    }
    
    private func setupWeeks() {
        let current = week(for: Date())
        let past = week(for: Calendar.current.date(byAdding: .day, value: -7, to: Date())!)
        let future = week(for: Calendar.current.date(byAdding: .day, value: 7, to: Date())!)
        weeks = [past, current, future]
        currentWeekIndex = 1
    }
    
    private func shiftWeeks(by offset: Int) {
        let centerDate = weeks[1][0]
        let newCenter = Calendar.current.date(byAdding: .day, value: offset * 7, to: centerDate)!
        weeks = [
            week(for: Calendar.current.date(byAdding: .day, value: -7, to: newCenter)!),
            week(for: newCenter),
            week(for: Calendar.current.date(byAdding: .day, value: 7, to: newCenter)!)
        ]
        currentWeekIndex = 1
    }
    
    private func week(for date: Date) -> [Date] {
        var cal = Calendar.current
        cal.firstWeekday = 2
        let comp = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        let startOfWeek = cal.date(from: comp)!
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
}

struct DayCell: View {
    let date: Date
    let selectedDate: Date
    let checkins: [Checkin]
    
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
    private var isSelected: Bool { Calendar.current.isDate(date, inSameDayAs: selectedDate) }
    private var isToday: Bool { Calendar.current.isDateInToday(date) }
    private var isFuture: Bool { date > Date() && !isToday }
    
    private var hasCheckin: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        return checkins.contains { $0.dateString == dateString }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(weekdays[Calendar.current.component(.weekday, from: date) - 1])
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            // Pill
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected ? .bold : .semibold))
                    .foregroundColor(isSelected ? .white : (isFuture ? Color.gray.opacity(0.5) : .primary))
                
                ZStack {
                    if hasCheckin {
                        Circle()
                            .fill(isSelected ? .white : Color(hex: "#10B981"))
                            .frame(width: 14, height: 14)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(isSelected ? Color(hex: "#8B5CF6") : .white)
                            )
                    } else {
                        Circle()
                            .stroke(isSelected ? Color.white.opacity(0.4) : Color.gray.opacity(0.3), lineWidth: 1)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .frame(width: 40, height: 48)
            .padding(.top, 8)
            .padding(.bottom, 6)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(hex: "#8B5CF6"))
                            .shadow(color: Color(hex: "#8B5CF6").opacity(0.3), radius: 6, y: 3)
                    }
                    if isToday {
                        VStack {
                            Spacer()
                            Rectangle()
                                .fill(isSelected ? .white : Color(hex: "#8B5CF6"))
                                .frame(width: 16, height: 3)
                                .cornerRadius(1.5)
                                .padding(.bottom, 4)
                        }
                    }
                }
            )
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}
struct CustomTopCorners: Shape {
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: 0))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: radius), radius: radius, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct HabitCard: View {
    let habit: Habit
    let selectedDate: Date
    let checkins: [Checkin]
    let onCheckin: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    var isChecked: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        return checkins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateString })
    }
    
    var progressText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Quick weekly approximation for UI display
        let hCheckins = checkins.filter { $0.habit?.id == habit.id }
        
        let freqLabel = habit.frequencyType == "weekly" ? "周" : "月"
        if habit.goalType == "amount" {
            let target = habit.amountValue
            // sum of today for simplicity in UI, fully calculating period requires complex date logic here
            let sum = hCheckins.filter { $0.dateString == formatter.string(from: selectedDate) }.reduce(0) { $0 + $1.amount }
            return "\(freqLabel): \(sum)/\(target)\(habit.amountUnit)"
        } else {
            let target = habit.frequencyType == "weekly" ? habit.weeklyTarget : habit.monthlyTarget
            // sum of today for simplicity
            let count = hCheckins.filter { $0.dateString == formatter.string(from: selectedDate) }.count
            return "\(freqLabel): \(count)/\(target)次"
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(isChecked ? Color(hex: "#10B981") : Color(hex: habit.color))
                    .frame(width: 50, height: 50)
                    .shadow(color: isChecked ? Color(hex: "#10B981").opacity(0.4) : Color(hex: habit.color).opacity(0.4), radius: 6, y: 3)
                
                if isChecked {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.title2)
                } else {
                    Image(systemName: habit.icon)
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isChecked)
            
            Text(habit.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isChecked ? Color(hex: "#10B981") : .primary)
                .lineLimit(1)
                .padding(.top, 4)
            
            Text(progressText)
                .font(.system(size: 10))
                .foregroundColor(isChecked ? Color(hex: "#10B981").opacity(0.8) : .secondary)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isChecked ? Color(hex: "#10B981").opacity(0.08) : Color.white.opacity(0.8))
                .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
        )
        .scaleEffect(scale)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                scale = 0.9
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    scale = 1.0
                }
                onCheckin()
            }
        }
    }
}

struct AmountCheckinSheet: View {
    @Environment(\.modelContext) private var modelContext
    let habit: Habit
    let selectedDate: Date
    let initialAmount: Double?
    let onComplete: () -> Void
    
    @State private var amountString: String = "0"
    
    let pad = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "DEL"]
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text(initialAmount != nil ? "修改\(habit.name)" : "记录\(habit.name)")
                .font(.headline)
                .padding(.top, 20)
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(amountString)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color(hex: habit.color))
                Text(habit.amountUnit)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .frame(height: 60)
            
            VStack(spacing: 12) {
                ForEach(pad, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { key in
                            Button(action: { handleKey(key) }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(UIColor.systemGray6))
                                        .frame(height: 56)
                                    
                                    if key == "DEL" {
                                        Image(systemName: "delete.left.fill").foregroundColor(.gray).font(.title2)
                                    } else {
                                        Text(key).font(.title2).fontWeight(.semibold).foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Button(action: submit) {
                Text(initialAmount != nil ? "保存修改" : "完成打卡")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(hex: habit.color))
                    .cornerRadius(26)
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            
            Spacer()
        }
        .onAppear {
            if let initial = initialAmount {
                // If it's a whole number, remove .0
                if floor(initial) == initial {
                    amountString = String(Int(initial))
                } else {
                    amountString = String(initial)
                }
            }
        }
    }
    
    private func handleKey(_ key: String) {
        if key == "DEL" {
            if amountString.count > 1 { amountString.removeLast() } else { amountString = "0" }
        } else if key == "." {
            if !amountString.contains(".") { amountString += "." }
        } else {
            if amountString == "0" { amountString = key } else if amountString.count < 6 { amountString += key }
        }
    }
    
    private func submit() {
        let val = Double(amountString) ?? 0.0
        if val > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: selectedDate)
            
            if initialAmount != nil {
                // We shouldn't fetch here directly from checkins array since it's not passed,
                // but we can query it or simply insert a new one if we delete the old one.
                // In SwiftUI, we just create a new Checkin and replace or simply update.
                let targetId = habit.id
                let descriptor = FetchDescriptor<Checkin>(predicate: #Predicate { $0.dateString == dateString && $0.habit?.id == targetId })
                if let existing = try? modelContext.fetch(descriptor).first {
                    existing.amount = val
                }
            } else {
                let newCheckin = Checkin(dateString: dateString, amount: val)
                newCheckin.habit = habit
                modelContext.insert(newCheckin)
            }
            onComplete()
        }
    }
}

// Confetti View
struct ConfettiView: View {
    @State private var animate = false
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<50, id: \.self) { i in
                    ConfettiParticle(
                        color: colors.randomElement()!,
                        animate: $animate,
                        screenSize: geometry.size
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiParticle: View {
    let color: Color
    @Binding var animate: Bool
    let screenSize: CGSize
    
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    @State private var rotation: Double = 0
    
    let startX = CGFloat.random(in: 0.3...0.7)
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 6...12))
            .position(x: screenSize.width * startX, y: screenSize.height * 0.4)
            .offset(x: xOffset, y: yOffset)
            .rotationEffect(.degrees(rotation))
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: Double.random(in: 1.5...2.5))) {
                    xOffset = CGFloat.random(in: -200...200)
                    yOffset = CGFloat.random(in: -300...300)
                    rotation = Double.random(in: 360...1080)
                }
            }
    }
}
