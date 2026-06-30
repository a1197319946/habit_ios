import SwiftUI
import SwiftData

struct CheckinSuccessView: View {
    @Environment(\.dismiss) private var dismiss
    
    let habit: Habit
    let date: Date
    let checkins: [Checkin]
    let onRecordMood: () -> Void
    
    @State private var isGenerating = false
    @State private var appeared = false
    
    private var isAmount: Bool { habit.goalType == "amount" }
    private var unit: String { isAmount ? habit.amountUnit : "次" }
    private var label: String { habit.frequencyType == "weekly" ? "本周" : "本月" }
    private var targetLabel: String { habit.frequencyType == "weekly" ? "周目标" : "月目标" }
    
    private var target: Double {
        if isAmount { return habit.amountValue }
        return Double(habit.frequencyType == "weekly" ? habit.weeklyTarget : habit.monthlyTarget)
    }
    
    private var currentTotal: Double {
        let periodCheckins = checkins.filter { $0.habit?.id == habit.id }
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
        VStack(spacing: 0) {
            // Top drag handle area
            RoundedRectangle(cornerRadius: 2)
                .fill(DS.borderStrong)
                .frame(width: 40, height: 4)
                .padding(.top, DS.spacingL)
                .padding(.bottom, DS.spacingM)
            
            // Close button row
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(DS.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(DS.bgSubtle)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, DS.spacingL)
            .padding(.bottom, DS.spacingM)
            
            // Icon + name
            VStack(spacing: DS.spacingM) {
                ZStack {
                    Circle()
                        .fill(DS.successMuted)
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: habit.icon)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(DS.success)
                }
                .scaleEffect(appeared ? 1.0 : 0.6)
                .animation(.spring(response: 0.4, dampingFraction: 0.65), value: appeared)
                
                VStack(spacing: 4) {
                    Text("打卡成功")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(DS.textPrimary)
                    
                    Text(habit.name)
                        .font(.system(size: 15))
                        .foregroundColor(DS.textSecondary)
                }
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.3).delay(0.1), value: appeared)
            }
            .padding(.bottom, DS.spacingL)
            
            // Stats
            HStack(spacing: 0) {
                StatCell(label: "本次完成", value: formatNumber(todayAmount), unit: unit, accent: true)
                
                Rectangle()
                    .fill(DS.border)
                    .frame(width: 1, height: 48)
                
                StatCell(label: "\(label)累计", value: formatNumber(currentTotal), unit: unit, accent: false)
                
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
                    Text("\(targetLabel)已达成！")
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
                
                Button(action: generatePoster) {
                    HStack {
                        if isGenerating {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: DS.textSecondary))
                        }
                        Text(isGenerating ? "生成中..." : "生成分享图")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DS.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(DS.bgSubtle)
                    .cornerRadius(DS.cornerPill)
                }
                .disabled(isGenerating)
            }
            .padding(.horizontal, DS.spacingL)
            .padding(.bottom, DS.spacingXL)
        }
        .background(DS.bgPrimary)
        .onAppear {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            appeared = true
        }
    }
    
    private func formatNumber(_ val: Double) -> String {
        val.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", val) : String(format: "%.1f", val)
    }
    
    @MainActor
    private func generatePoster() {
        isGenerating = true
        let posterView = PosterView(habit: habit, date: date, checkins: checkins)
        let renderer = ImageRenderer(content: posterView)
        renderer.scale = 3.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let uiImage = renderer.uiImage {
                let activityVC = UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = scene.windows.first,
                   let rootVC = window.rootViewController {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        activityVC.popoverPresentationController?.sourceView = window
                        rootVC.present(activityVC, animated: true, completion: nil)
                    }
                }
            }
            isGenerating = false
        }
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

// MARK: - Poster View (Clean Japandi poster)

struct PosterView: View {
    let habit: Habit
    let date: Date
    let checkins: [Checkin]
    
    private var totalCheckins: Int {
        checkins.filter { $0.habit?.id == habit.id }.count
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#F7F4EF") // Warm off-white
            
            VStack(alignment: .leading, spacing: 0) {
                // Top accent bar
                Rectangle()
                    .fill(Color(hex: habit.color))
                    .frame(height: 6)
                
                VStack(alignment: .leading, spacing: 32) {
                    // Date
                    VStack(alignment: .leading, spacing: 4) {
                        Text(monthName())
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#9B9088"))
                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.system(size: 72, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(hex: "#2D2D2D"))
                    }
                    .padding(.top, 40)
                    
                    // Habit
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: habit.color).opacity(0.15))
                                .frame(width: 56, height: 56)
                            Image(systemName: habit.icon)
                                .font(.system(size: 26))
                                .foregroundColor(Color(hex: habit.color))
                        }
                        Text(habit.name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#2D2D2D"))
                    }
                    
                    // Divider
                    Rectangle()
                        .fill(Color(hex: "#EAE6E0"))
                        .frame(height: 1)
                    
                    // Quote
                    Text("人生没有白走的路，\n每一步都算数。")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#2D2D2D"))
                        .lineSpacing(6)
                    
                    // Stats
                    HStack(spacing: 40) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("今日")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "#9B9088"))
                            Text("1 次")
                                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                                .foregroundColor(Color(hex: habit.color))
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("累计")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "#9B9088"))
                            Text("\(totalCheckins) 次")
                                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                                .foregroundColor(Color(hex: "#2D2D2D"))
                        }
                    }
                    
                    Spacer()
                    
                    // Bottom branding
                    HStack {
                        Text("小习惯")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "#9B9088"))
                        Spacer()
                        Image("app_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    }
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 32)
            }
        }
        .frame(width: 390, height: 690)
    }
    
    private func monthName() -> String {
        let months = ["January", "February", "March", "April", "May", "June",
                      "July", "August", "September", "October", "November", "December"]
        return months[Calendar.current.component(.month, from: date) - 1].uppercased()
    }
}
