import SwiftUI

struct CheckinSuccessView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appSettings: AppSettings
    
    let habit: Habit
    let date: Date
    let checkins: [Checkin]
    let onRecordMood: () -> Void
    
    @State private var isGenerating = false
    @State private var appeared = false
    @State private var showSharePreview = false
    
    private var isAmount: Bool { habit.goalType == "amount" }
    private var unit: String { isAmount ? (habit.amountUnit ?? "次").tr(appSettings.resolvedLanguage) : "次".tr(appSettings.resolvedLanguage) }
    private var label: String { (habit.frequencyType == "weekly" ? "本周" : "本月").tr(appSettings.resolvedLanguage) }
    private var targetLabel: String { (habit.frequencyType == "weekly" ? "周目标" : "月目标").tr(appSettings.resolvedLanguage) }
    
    private var target: Double {
        if isAmount { return habit.amountValue }
        return Double(habit.frequencyType == "weekly" ? habit.weeklyTarget : habit.monthlyTarget)
    }
    
    private var currentTotal: Double {
                var calendar = Calendar.current
        calendar.firstWeekday = UserDefaults.standard.integer(forKey: "firstWeekday") == 0 ? 2 : UserDefaults.standard.integer(forKey: "firstWeekday")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let periodCheckins = checkins.filter { checkin in
            guard checkin.habit?.id == habit.id,
                  let cDate = formatter.date(from: checkin.dateString) else { return false }
            
            if habit.frequencyType == "weekly" {
                return calendar.isDate(cDate, equalTo: date, toGranularity: .weekOfYear)
            } else {
                return calendar.isDate(cDate, equalTo: date, toGranularity: .month)
            }
        }
        
        return isAmount ? periodCheckins.reduce(0) { $0 + $1.amount } : Double(periodCheckins.count)
    }
    
    private var todayAmount: Double {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        let todayCheckins = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateString }
        return isAmount ? todayCheckins.reduce(0) { $0 + $1.amount } : (todayCheckins.isEmpty ? 0 : 1)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
            Spacer().frame(height: 64)
            // Header + Icon + Name
            VStack(spacing: 12) {
                Text("Check-in Successful".tr(appSettings.resolvedLanguage))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(DS.textPrimary)
                
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: habit.color).opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: habit.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: habit.color))
                    }
                    
                    Text(habit.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DS.textSecondary)
                }
            }
            .padding(.bottom, 32)
            
            // Stats
            HStack(spacing: 0) {
                StatCell(label: "Amount Completed".tr(appSettings.resolvedLanguage), value: formatNumber(todayAmount), unit: unit, accent: true)
                
                Rectangle()
                    .fill(DS.border)
                    .frame(width: 1, height: 48)
                
                StatCell(label: "\(label)\(" Total".tr(appSettings.resolvedLanguage))", value: formatNumber(currentTotal), unit: unit, accent: false)
                
                Rectangle()
                    .fill(DS.border)
                    .frame(width: 1, height: 48)
                
                StatCell(label: targetLabel, value: formatNumber(target), unit: unit, accent: false)
            }
            .padding(DS.spacingL)
            .card()
            .padding(.horizontal, DS.spacingL)
            
            // Goal achieved badge
            if currentTotal >= target && target > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(DS.success)
                    Text("\(targetLabel)\(" Achieved!".tr(appSettings.resolvedLanguage))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DS.success)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, DS.spacingL)
                .background(DS.successMuted)
                .cornerRadius(DS.cornerPill)
                .padding(.top, DS.spacingM)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: DS.spacingS) {
                Button(action: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onRecordMood() }
                }) {
                    Text("Record Mood".tr(appSettings.resolvedLanguage))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(DS.primary)
                        .cornerRadius(DS.cornerPill)
                }
                
                Button(action: { showSharePreview = true }) {
                    HStack {
                        Text("Generate Sharing Image".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DS.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(DS.primary.opacity(0.12))
                    .cornerRadius(DS.cornerPill)
                }
                
            }
            .padding(.horizontal, DS.spacingL)
            .padding(.bottom, DS.spacingXL)
        }
        .background(DS.bgPrimary)
            .onAppear {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                appeared = true
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSharePreview) {
                SharePreviewSheet(habit: habit, date: date, checkins: checkins, isAmount: isAmount, todayAmount: todayAmount, currentTotal: currentTotal, unit: unit)
            }

        }
    }
    
    private func formatNumber(_ val: Double) -> String {
        val.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", val) : String(format: "%.1f", val)
    }
}

// MARK: - Stat Cell

struct StatCell: View {
    let label: String
    let value: String
    let unit: String
    let accent: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DS.textSecondary)
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(accent ? DS.accent : DS.textPrimary)
                Text(unit)
                    .font(.system(size: 12))
                    .foregroundColor(DS.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

    

struct SharePreviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appSettings: AppSettings
    
    let habit: Habit
    let date: Date
    let checkins: [Checkin]
    let isAmount: Bool
    let todayAmount: Double
    let currentTotal: Double
    let unit: String
    
    @State private var isGenerating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F5F7FA").ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer(minLength: 10)
                    
                    let scale: CGFloat = 0.65
                    PosterView(habit: habit, date: date, checkins: checkins, isAmount: isAmount, todayAmount: todayAmount, currentTotal: currentTotal, unit: unit, appSettings: appSettings)
                        .environment(\.colorScheme, .light)
                        .colorScheme(.light)
                        .scaleEffect(scale)
                        .frame(width: 414 * scale, height: 736 * scale)
                        .shadow(color: Color.black.opacity(0.15), radius: 20, y: 10)
                        .zIndex(100)
                    
                    Spacer(minLength: 10)
                    
                    Button(action: generatePoster) {
                        HStack {
                            if isGenerating {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share with Friends".tr(appSettings.resolvedLanguage))
                            }
                        }
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(DS.primary)
                        .cornerRadius(DS.cornerPill)
                        .shadow(color: DS.primary.opacity(0.3), radius: 10, y: 5)
                    }
                    .disabled(isGenerating)
                    .padding(.horizontal, DS.spacingXL)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Close".tr(appSettings.resolvedLanguage))
                            .foregroundColor(DS.primary)
                            .font(.system(size: 15, weight: .medium))
                    }
                }
            }
        }
        .preferredColorScheme(.light)
    }
    
    @MainActor
    private func generatePoster() {
        isGenerating = true
        let posterView = PosterView(habit: habit, date: date, checkins: checkins, isAmount: isAmount, todayAmount: todayAmount, currentTotal: currentTotal, unit: unit, appSettings: appSettings)
            .environment(\.colorScheme, .light)
            .colorScheme(.light)
            .preferredColorScheme(.light)
        let renderer = ImageRenderer(content: posterView)
        renderer.scale = 3.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let uiImage = renderer.uiImage {
                let activityVC = UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)
                if let topVC = getTopViewController() {
                    activityVC.popoverPresentationController?.sourceView = topVC.view
                    activityVC.popoverPresentationController?.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                    activityVC.popoverPresentationController?.permittedArrowDirections = []
                    topVC.present(activityVC, animated: true, completion: nil)
                }
            }
            isGenerating = false
        }
    }
    
    private func getTopViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseVC = base ?? (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first { $0.isKeyWindow }?.rootViewController
        if let nav = baseVC as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        }
        if let tab = baseVC as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopViewController(base: selected)
            }
        }
        if let presented = baseVC?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return baseVC
    }
}

// MARK: - Poster View

struct PosterView: View {
    let habit: Habit
    let date: Date
    let checkins: [Checkin]
    let isAmount: Bool
    let todayAmount: Double
    let currentTotal: Double
    let unit: String
    @ObservedObject var appSettings: AppSettings
    
    var body: some View {
        ZStack {
            // Solid base color to ensure dark mode background never bleeds through transparent gradients
            Color(hex: "#F9FAFC")
            
            // Premium Gradient Background
            LinearGradient(
                colors: [Color(hex: habit.color).opacity(0.15), Color(hex: "#F9FAFC"), Color(hex: "#F9FAFC")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 0) {
                // Top accent bar
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: habit.color), Color(hex: habit.color).opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 8)
                
                VStack(alignment: .leading, spacing: 32) {
                    // Date
                    VStack(alignment: .leading, spacing: 4) {
                        Text(monthName())
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: habit.color))
                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.system(size: 80, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(hex: "#1A1C1E"))
                    }
                    .padding(.top, 40)
                    
                    // Habit
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: habit.color).opacity(0.15))
                                .frame(width: 64, height: 64)
                            Image(systemName: habit.icon)
                                .font(.system(size: 30))
                                .foregroundColor(Color(hex: habit.color))
                        }
                        Text(habit.name)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#1A1C1E"))
                    }
                    
                    // Quote
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: "quote.opening")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(Color(hex: "#E0E2E5"))
                        
                        Text("\"Small steps, big changes.\"".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 24, weight: .semibold, design: .serif))
                            .foregroundColor(Color(hex: "#1A1C1E"))
                            .lineSpacing(8)
                    }
                    .padding(.vertical, 20)
                    
                    // Stats
                    HStack(spacing: 48) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Today".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "#7A7C7E"))
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(formatNumber(todayAmount))
                                    .font(.system(size: 36, weight: .black, design: .rounded))
                                    .foregroundColor(Color(hex: habit.color))
                                Text(unit)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: habit.color).opacity(0.8))
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Total".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "#7A7C7E"))
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(formatNumber(currentTotal))
                                    .font(.system(size: 36, weight: .black, design: .rounded))
                                    .foregroundColor(Color(hex: "#1A1C1E"))
                                Text(unit)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "#4A4C4E"))
                            }
                        }
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
                    
                    Spacer()
                    
                    // Bottom branding
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TickDay".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#4A4C4E"))
                            Text("Track your daily progress".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "#7A7C7E"))
                        }
                        Spacer()
                        Image("app_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 88, height: 88)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.black.opacity(0.12), radius: 6, y: 3)
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 40)
            }
        }
        .frame(width: 414, height: 736) // Fixed 16:9 ratio size for better posters
        .background(Color(hex: "#F9FAFC"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .environment(\.colorScheme, .light)
    }
    
    private func monthName() -> String {
        let f = DateFormatter()
        f.locale = appSettings.locale ?? Locale.current
        f.dateFormat = appSettings.resolvedLanguage == .chinese ? "yyyy年M月" : "MMM yyyy"
        return f.string(from: date).uppercased()
    }
    
    private func formatNumber(_ val: Double) -> String {
        val.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", val) : String(format: "%.1f", val)
    }
}
