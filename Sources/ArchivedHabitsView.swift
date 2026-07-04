import SwiftUI
import SwiftData

struct ArchivedHabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appSettings: AppSettings
    @Query(filter: #Predicate<Habit> { $0.isArchived == true }, sort: \Habit.order) private var habits: [Habit]
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            
            ScrollView {
                if habits.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "archivebox")
                            .font(.system(size: 48))
                            .foregroundColor(DS.outline)
                        Text("No archived habits.".tr(appSettings.resolvedLanguage))
                            .bodyLg()
                            .foregroundColor(DS.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(habits) { habit in
                            NavigationLink(value: habit) {
                                ArchivedHabitCard(habit: habit)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, DS.spacingL)
                    .padding(.top, DS.spacingM)
                }
            }
        }
        .background(Color(hex: "#F8F9FA").ignoresSafeArea())
        .navigationTitle("Archived Habits".tr(appSettings.resolvedLanguage))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ArchivedHabitCard: View {
    let habit: Habit
    @EnvironmentObject private var appSettings: AppSettings
    
    var body: some View {
        HStack(spacing: DS.spacingM) {
            ZStack {
                Circle()
                    .fill(Color(hex: habit.color).opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: habit.icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: habit.color))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DS.onSurface)
                Text(habit.frequencyType == "weekly" ? "Weekly".tr(appSettings.resolvedLanguage) : "Monthly".tr(appSettings.resolvedLanguage))
                    .bodyMd()
                    .foregroundColor(DS.onSurfaceVariant)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(DS.outline)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(DS.spacingM)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white, lineWidth: 1)
        )
        .shadow(color: DS.primary.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}
