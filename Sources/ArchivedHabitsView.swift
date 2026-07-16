import SwiftUI
import CoreData

struct ArchivedHabitsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appSettings: AppSettings
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.order, ascending: true)],
        predicate: NSPredicate(format: "isArchived == true")
    ) private var habits: FetchedResults<Habit> 
    
    var body: some View {
        ScrollView {
            if habits.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "archivebox")
                        .font(.system(size: 48))
                        .foregroundColor(DS.outline)
                    Text(L10n.noArchivedHabits.tr(appSettings.resolvedLanguage))
                        .bodyLg()
                        .foregroundColor(DS.onSurfaceVariant)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 100)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(habits) { habit in
                        NavigationLink(value: habit) {
                            ArchivedHabitCard(habit: habit)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, DS.spacingM)
            }
        }
        .background(AmbientBackground())
        .navigationTitle(L10n.archivedHabits.tr(appSettings.resolvedLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct ArchivedHabitCard: View {
    @ObservedObject var habit: Habit
    @EnvironmentObject private var appSettings: AppSettings
    
    private var targetText: String {
        let lang = appSettings.resolvedLanguage
        let freqStr = habit.frequencyType == "weekly" ? L10n.week2.tr(lang) : L10n.month3.tr(lang)
        if habit.goalType == "amount" {
            let formattedVal = habit.amountValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", habit.amountValue) : String(format: "%.1f", habit.amountValue)
            let unitStr = habit.amountUnit.tr(lang)
            return "\("目标: ".tr(lang))\(formattedVal) \(unitStr) / \(freqStr)"
        } else {
            let targetVal = habit.frequencyType == "weekly" ? habit.weeklyTarget : habit.monthlyTarget
            return "\("目标: ".tr(lang))\(targetVal) \(L10n.times1.tr(lang)) / \(freqStr)"
        }
    }
    
    var body: some View {
        HStack(spacing: DS.spacingM) {
            ZStack {
                Circle()
                    .fill(Color(hex: habit.color).opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: habit.icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: habit.color))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DS.onSurface)
                Text(targetText)
                    .bodyMd()
                    .foregroundColor(DS.onSurfaceVariant)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(DS.outline)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(DS.spacingM)
        .background(DS.surface.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(DS.outlineVariant, lineWidth: 1)
        )
        .shadow(color: DS.primary.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}
