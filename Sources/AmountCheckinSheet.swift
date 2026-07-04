import SwiftUI
import SwiftData

struct AmountCheckinSheet: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    let habit: Habit
    let selectedDate: Date
    let initialAmount: Double?
    let onComplete: () -> Void
    
    @State private var amountString: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: DS.spacingXL) {
                
                Spacer().frame(height: 20)
                
                HStack(alignment: .lastTextBaseline, spacing: 6) {
    TextField("0", text: $amountString)
                        .focused($isFocused)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: habit.color))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(minWidth: 40)
                    
                    Text(habit.amountUnit)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(DS.onSurfaceVariant)
                }
                .frame(height: 70)
                
                Spacer()
                
                Button(action: submit) {
                    Text(initialAmount != nil ? "Save Changes".tr(appSettings.resolvedLanguage) : "Check In".tr(appSettings.resolvedLanguage))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(DS.primary)
                        .cornerRadius(DS.cornerPill)
                }
                .padding(.horizontal, DS.spacingL)
                .padding(.bottom, DS.spacingL)
                .disabled(Double(amountString) == nil || Double(amountString) == 0)
            }
            .background(DS.background)
            .navigationTitle(initialAmount != nil ? "\("Edit".tr(appSettings.resolvedLanguage)) \(habit.name)" : "\("Check in".tr(appSettings.resolvedLanguage)) \(habit.name)")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let initial = initialAmount {
                    amountString = floor(initial) == initial ? String(Int(initial)) : String(initial)
                }
            }
        }
    }
    
    private func submit() {
        let val = Double(amountString) ?? 0.0
        if val > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: selectedDate)
            
            if initialAmount != nil {
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
            try? modelContext.save()
            isFocused = false
            onComplete()
            dismiss()
        }
    }
}
