import SwiftUI
import SwiftData
import WidgetKit

struct AmountCheckinSheet: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    
    // We fetch checkins to calculate accumulation
    @Query private var allCheckins: [Checkin]
    
    let habit: Habit
    let selectedDate: Date
    let initialAmount: Double?
    let onComplete: () -> Void
    
    @State private var amountString: String = ""
    
    // Calculate period start and end
    private var periodInterval: DateInterval? {
                var calendar = Calendar.current
        calendar.firstWeekday = UserDefaults.standard.integer(forKey: "firstWeekday") == 0 ? 2 : UserDefaults.standard.integer(forKey: "firstWeekday")
        let targetComponent: Calendar.Component = habit.frequencyType == "weekly" ? .weekOfYear : .month
        return calendar.dateInterval(of: targetComponent, for: selectedDate)
    }
    
    // Calculate accumulated
    private var accumulatedAmount: Double {
        guard let interval = periodInterval else { return 0.0 }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let validCheckins = allCheckins.filter { checkin in
            guard checkin.habit?.id == habit.id else { return false }
            guard let date = formatter.date(from: checkin.dateString) else { return false }
            return date >= interval.start && date < interval.end
        }
        
        return validCheckins.reduce(0.0) { $0 + $1.amount }
    }
    
    private var periodTarget: Double {
        return habit.amountValue
    }
    
    private var isEditing: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        return allCheckins.contains(where: { $0.habit?.id == habit.id && $0.dateString == dateString })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(isEditing ? "Edit Data".tr(appSettings.resolvedLanguage) : "Enter Data".tr(appSettings.resolvedLanguage))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(DS.onSurface)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DS.onSurfaceVariant)
                        .padding(8)
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, DS.spacingL)
            .padding(.bottom, 24)
            
            // Habit Info Card
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(hex: habit.color).opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: habit.icon)
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: habit.color))
                }
                
                // Text info
                VStack(alignment: .leading, spacing: 6) {
                    Text(habit.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DS.onSurface)
                    
                    let targetFormatted = formatDouble(periodTarget)
                    let accFormatted = formatDouble(accumulatedAmount)
                    
                    Text("\("Period Target: ".tr(appSettings.resolvedLanguage))\(targetFormatted) \(habit.amountUnit.tr(appSettings.resolvedLanguage))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DS.onSurfaceVariant)
                    
                    Text("\("Period Total: ".tr(appSettings.resolvedLanguage))\(accFormatted) \(habit.amountUnit.tr(appSettings.resolvedLanguage))")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: "#5856D6")) // Blue-ish color matching screenshot
                }
                
                Spacer()
            }
            .padding(16)
            .background(DS.surfaceVariant)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, DS.spacingL)
            
            // Input Area
            VStack(alignment: .leading, spacing: 12) {
                Text("Amount Completed".tr(appSettings.resolvedLanguage))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DS.onSurface)
                    .padding(.horizontal, DS.spacingL)
                    .padding(.top, 32)
                
                ZStack(alignment: .trailing) {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(DS.surface)
                        .frame(height: 100)
                    
                    TextField("0", text: $amountString)
                        .focused($isFocused)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundColor(DS.onSurface)
                        .multilineTextAlignment(.center)
                    
                    Text(habit.amountUnit.tr(appSettings.resolvedLanguage))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DS.onSurface)
                        .padding(.trailing, 24)
                }
                .padding(.horizontal, DS.spacingL)
            }
            
            Spacer()
            
            // Submit Button
            Button(action: submit) {
                Text(isEditing ? "Save Changes".tr(appSettings.resolvedLanguage) : "Check In".tr(appSettings.resolvedLanguage))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(DS.primary)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, DS.spacingL)
            .padding(.bottom, 32)
            .disabled(Double(amountString) == nil || Double(amountString) == 0)
            .opacity((Double(amountString) == nil || Double(amountString) == 0) ? 0.6 : 1.0)
        }
        .background(DS.surface)
        .presentationDetents([.height(640)])
        .onAppear {
            if isEditing, let initial = initialAmount, initial > 0 {
                amountString = formatDouble(initial)
            } else {
                amountString = ""
            }
            // Auto focus
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isFocused = true
            }
        }
    }
    
    private func formatDouble(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
    
    private func submit() {
        let val = Double(amountString) ?? 0.0
        if val > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: selectedDate)
            
            let targetId = habit.id
            let descriptor = FetchDescriptor<Checkin>(predicate: #Predicate { $0.dateString == dateString && $0.habit?.id == targetId })
            if let existing = try? modelContext.fetch(descriptor).first {
                existing.amount = val
            } else {
                let newCheckin = Checkin(dateString: dateString, amount: val)
                newCheckin.habit = habit
                modelContext.insert(newCheckin)
            }
            try? modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
            isFocused = false
            onComplete()
            dismiss()
        }
    }
}
