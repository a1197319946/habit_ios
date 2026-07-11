import re

with open("Sources/CheckinSuccessView.swift", "r") as f:
    content = f.read()

# 1. Update unit translation
content = content.replace('private var unit: String { isAmount ? habit.amountUnit : "次" }', 
                          'private var unit: String { isAmount ? habit.amountUnit.tr(appSettings.resolvedLanguage) : "次".tr(appSettings.resolvedLanguage) }')

# 2. Add state
content = content.replace('@State private var appeared = false', 
                          '@State private var appeared = false\n    @State private var showSharePreview = false')

# 3. Change button action
content = content.replace('Button(action: generatePoster) {', 
                          'Button(action: { showSharePreview = true }) {')

# 4. Remove old generating logic
content = re.sub(r' *if isGenerating \{\n *ProgressView\(\)\.progressViewStyle\(CircularProgressViewStyle\(tint: DS\.textSecondary\)\)\n *\}\n', '', content)
content = content.replace('Text(isGenerating ? "生成中..." : "生成分享图")', 'Text("Generate Sharing Image".tr(appSettings.resolvedLanguage))')
content = content.replace('.disabled(isGenerating)', '')

# 5. Add sheet modifier and replace generatePoster/PosterView
sheet_code = """        .background(DS.bgPrimary)
            .onAppear {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                appeared = true
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSharePreview) {
                SharePreviewSheet(habit: habit, date: date, checkins: checkins, isAmount: isAmount, todayAmount: todayAmount, currentTotal: currentTotal, unit: unit)
            }
"""

content = content.replace("""        .background(DS.bgPrimary)
            .onAppear {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                appeared = true
            }
            .navigationBarHidden(true)""", sheet_code)

# 6. Replace generatePoster and PosterView with new components
new_components = """
struct SharePreviewSheet: View {
    @Environment(\\.dismiss) private var dismiss
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
                
                VStack(spacing: DS.spacingL) {
                    Spacer()
                    
                    PosterView(habit: habit, date: date, checkins: checkins, isAmount: isAmount, todayAmount: todayAmount, currentTotal: currentTotal, unit: unit, appSettings: appSettings)
                        .scaleEffect(0.8)
                        .shadow(color: Color.black.opacity(0.1), radius: 20, y: 10)
                    
                    Spacer()
                    
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
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
                        Text("\\(Calendar.current.component(.day, from: date))")
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
                        
                        Text("\\"Small steps, big changes.\\"".tr(appSettings.resolvedLanguage))
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
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
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
"""

content = re.sub(r'    @MainActor\n    private func generatePoster\(\) \{[\s\S]*$', new_components, content)

with open("Sources/CheckinSuccessView.swift", "w") as f:
    f.write(content)

