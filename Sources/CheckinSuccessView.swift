import SwiftUI
import SwiftData

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
    private var unit: String { isAmount ? habit.amountUnit.tr(appSettings.resolvedLanguage) : "次".tr(appSettings.resolvedLanguage) }
    private var label: String { habit.frequencyType == "weekly" ? "本周" : "本月" }
    private var targetLabel: String { habit.frequencyType == "weekly" ? "周目标" : "月目标" }
    
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
                    Text("记录心情")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(DS.accent)
                        .cornerRadius(DS.cornerPill)
                }
                
                Button(action: { showSharePreview = true }) {
                    HStack {
                        Text("Generate Sharing Image".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DS.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(DS.bgSubtle)
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
                DS.bgPrimary.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DS.spacingL) {
                        PosterView(habit: habit, date: date, checkins: checkins, isAmount: isAmount, todayAmount: todayAmount, currentTotal: currentTotal, unit: unit, appSettings: appSettings)
                            .scaleEffect(0.8)
                            .shadow(color: Color.black.opacity(0.1), radius: 20, y: 10)
                        
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
                        .padding(.bottom, DS.spacingL)
                    }
                    .padding(.top, DS.spacingM)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Close".tr(appSettings.resolvedLanguage))
                            .foregroundColor(DS.textPrimary)
                    }
                }
            }
        }
    }
    
    @MainActor
    private func generatePoster() {
        isGenerating = true
        let posterView = PosterView(habit: habit, date: date, checkins: checkins, isAmount: isAmount, todayAmount: todayAmount, currentTotal: currentTotal, unit: unit, appSettings: appSettings)
        let renderer = ImageRenderer(content: posterView)
        renderer.scale = 3.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let uiImage = renderer.uiImage {
                let activityVC = UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = scene.windows.first,
                   let rootVC = window.rootViewController {
                    activityVC.popoverPresentationController?.sourceView = window
                    
                    // Dismiss the preview sheet first, then present the activity VC on the root
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        rootVC.present(activityVC, animated: true, completion: nil)
                    }
                }
            }
            isGenerating = false
        }
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
    let appSettings: AppSettings
    
    var body: some View {
        ZStack {
            // Premium Gradient Background
            LinearGradient(
                colors: [Color(hex: habit.color).opacity(0.1), DS.bgPrimary, DS.bgPrimary],
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
                            .foregroundColor(DS.textPrimary)
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
                            .foregroundColor(DS.textPrimary)
                    }
                    
                    // Quote
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: "quote.opening")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(DS.surfaceVariant)
                        
                        Text("\"Small steps, big changes.\"".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 24, weight: .semibold, design: .serif))
                            .foregroundColor(DS.textPrimary)
                            .lineSpacing(8)
                    }
                    .padding(.vertical, 20)
                    
                    // Stats
                    HStack(spacing: 48) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Today".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(DS.textTertiary)
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
                                .foregroundColor(DS.textTertiary)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(formatNumber(currentTotal))
                                    .font(.system(size: 36, weight: .black, design: .rounded))
                                    .foregroundColor(DS.textPrimary)
                                Text(unit)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(DS.textSecondary)
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
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Little Habit Tracker")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(DS.textSecondary)
                            Text("Track your daily progress")
                                .font(.system(size: 12))
                                .foregroundColor(DS.textTertiary)
                        }
                        Spacer()
                        Image("app_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 65, height: 65)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, y: 2)
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 40)
            }
        }
        .frame(width: 414, height: 736) // Fixed 16:9 ratio size for better posters
        .clipShape(RoundedRectangle(cornerRadius: 24))
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
