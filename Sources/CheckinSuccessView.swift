import SwiftUI
import SwiftData

struct CheckinSuccessView: View {
    @Environment(\.dismiss) private var dismiss
    
    let habit: Habit
    let date: Date
    let checkins: [Checkin]
    let onRecordMood: () -> Void
    
    @State private var showPoster = false
    @State private var isGenerating = false
    
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
        if isAmount {
            return periodCheckins.reduce(0) { $0 + $1.amount }
        } else {
            return Double(periodCheckins.count)
        }
    }
    
    private var todayAmount: Double {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        let todayCheckins = checkins.filter { $0.habit?.id == habit.id && $0.dateString == dateString }
        if isAmount {
            return todayCheckins.reduce(0) { $0 + $1.amount }
        } else {
            return todayCheckins.isEmpty ? 0 : 1
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("打卡成功").font(.system(size: 18, weight: .bold))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color(hex: "#9CA3AF"))
                        .font(.system(size: 20))
                }
            }
            .padding(24)
            
            VStack(spacing: 12) {
                HStack {
                    Text("目标进展").font(.system(size: 14, weight: .semibold))
                    Spacer()
                }
                
                HStack {
                    Text("本次完成").font(.system(size: 14)).foregroundColor(.secondary)
                    Spacer()
                    Text("\(formatNumber(todayAmount)) \(unit)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#8B5CF6"))
                }
                
                HStack {
                    Text("\(label)累计").font(.system(size: 14)).foregroundColor(.secondary)
                    Spacer()
                    Text("\(formatNumber(currentTotal)) \(unit)")
                        .font(.system(size: 15, weight: .semibold))
                }
                
                HStack {
                    Text(targetLabel).font(.system(size: 14)).foregroundColor(.secondary)
                    Spacer()
                    Text("\(formatNumber(target)) \(unit)")
                        .font(.system(size: 15, weight: .semibold))
                }
                
                if currentTotal >= target {
                    Divider().padding(.vertical, 8)
                    Text("🎉 \(targetLabel)已达成！")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#10B981"))
                }
            }
            .padding(20)
            .background(Color(hex: "#F9FAFB"))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#F3F4F6"), lineWidth: 1))
            .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                Button(action: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onRecordMood()
                    }
                }) {
                    Text("记心情")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "#8B5CF6"))
                        .cornerRadius(26)
                        .shadow(color: Color(hex: "#8B5CF6").opacity(0.3), radius: 8, y: 4)
                }
                
                Button(action: generatePoster) {
                    HStack {
                        if isGenerating {
                            ProgressView().progressViewStyle(CircularProgressViewStyle())
                        }
                        Text(isGenerating ? "生成中..." : "生成分享海报")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.white)
                    .cornerRadius(26)
                    .overlay(RoundedRectangle(cornerRadius: 26).stroke(Color(hex: "#E5E7EB"), lineWidth: 1))
                }
                .disabled(isGenerating)
            }
            .padding(24)
            .padding(.bottom, 10)
        }
        .background(Color.white)
    }
    
    private func formatNumber(_ val: Double) -> String {
        return val.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", val) : String(format: "%.1f", val)
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

struct PosterView: View {
    let habit: Habit
    let date: Date
    let checkins: [Checkin]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("poster_bg")
                .resizable()
                .scaledToFill()
                .frame(width: 470.5, height: 836)
                .clipped()
            
            let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            Text(monthNames[Calendar.current.component(.month, from: date) - 1])
                .font(.system(size: 18))
                .foregroundColor(.white)
                .position(x: 356 + 18, y: 66.5 + 9)
            
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color(hex: "#7E22CE"))
                .position(x: 351.5 + 20, y: 103.5 + 18)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("人生没有白走的路，")
                Text("每一步都算数。")
            }
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(Color(hex: "#111827"))
            .position(x: 53.5 + 80, y: 219.5 + 30)
            
            HStack(alignment: .bottom, spacing: 15) {
                Text(habit.name)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color(hex: "#7E22CE"))
                
                Image(systemName: habit.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(Color(hex: habit.color))
                    .cornerRadius(8)
                    .padding(.bottom, 6)
            }
            .position(x: 150, y: 405 + 20)
            
            HStack(spacing: 80) {
                VStack(spacing: 4) {
                    Text("1")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(Color(hex: "#7E22CE"))
                    Text("次")
                        .font(.system(size: 20))
                }
                
                VStack(spacing: 4) {
                    Text("\(checkins.filter { $0.habit?.id == habit.id }.count)")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(Color(hex: "#7E22CE"))
                    Text("次")
                        .font(.system(size: 20))
                }
            }
            .position(x: 235.25, y: 588.5 + 30)
            
            Image("scancode")
                .resizable()
                .frame(width: 72, height: 72)
                .position(x: 59 + 36, y: 699.5 + 36)
        }
        .frame(width: 470.5, height: 836)
    }
}
