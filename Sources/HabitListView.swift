import SwiftUI
import SwiftData
import WidgetKit

struct HabitListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appSettings: AppSettings
    @Query(filter: #Predicate<Habit> { $0.isArchived == false }, sort: \Habit.order) private var habits: [Habit]
    
    @State private var showingAddSheet = false
    @State private var draggedHabit: Habit?
    @State private var navigateToAddHabit = false
    @State private var editingHabit: Habit?
    @State private var showPaywall = false
    @State private var localHabits: [Habit] = []
    @State private var habitToDelete: Habit?
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Habit".tr(appSettings.resolvedLanguage))
                                .display()
                                .foregroundColor(DS.primary)
                            Text("You have ".tr(appSettings.resolvedLanguage))
                                .bodyLg()
                                .foregroundColor(DS.onSurfaceVariant) + 
                            Text("\(habits.count)")
                                .bodyLg()
                                .foregroundColor(DS.primary)
                                .bold() +
                            Text(" habits.".tr(appSettings.resolvedLanguage))
                                .bodyLg()
                                .foregroundColor(DS.onSurfaceVariant)
                        }
                        
                        Spacer()
                        
                        NavigationLink(value: "archived_habits") {
                            Image(systemName: "archivebox")
                                .font(.system(size: 20))
                                .foregroundColor(DS.primary)
                                .padding(8)
                                .background(DS.surface.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.05), radius: 5)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, DS.spacingM)
                    .padding(.bottom, DS.spacingM)
                    .padding(.horizontal, 16)
                    
                    // Habit List
                    if localHabits.isEmpty {
                        EmptyHabitsView(onAction: nil)
                            .padding(.top, 100)
                            .padding(.horizontal, 16)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(localHabits) { habit in
                                NavigationLink(value: habit) {
                                    HabitListCard(habit: habit)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contextMenu {
                                    Button(action: { editingHabit = habit }) {
                                        Label("Edit".tr(appSettings.resolvedLanguage), systemImage: "pencil")
                                    }
                                        Button(action: {
                                            NotificationManager.shared.cancelReminder(for: habit)
                                            habit.isArchived = true
                                            try? modelContext.save()
                                            WidgetCenter.shared.reloadAllTimelines()
                                        }) {
                                            Label("Archive".tr(appSettings.resolvedLanguage), systemImage: "archivebox")
                                        }
                                        
                                        Button(role: .destructive, action: {
                                            habitToDelete = habit
                                            showDeleteAlert = true
                                        }) {
                                            Label("Delete".tr(appSettings.resolvedLanguage), systemImage: "trash")
                                        }
                                    }
                                    .onDrag {
                                        self.draggedHabit = habit
                                        return NSItemProvider(object: habit.id as NSString)
                                    } preview: {
                                        HabitListCard(habit: habit)
                                            .environmentObject(appSettings)
                                            .frame(width: UIScreen.main.bounds.width - 32)
                                    }
                                    .onDrop(of: [.text], delegate: HabitDropDelegate(item: habit, habits: $localHabits, draggedHabit: $draggedHabit, modelContext: modelContext))
                                    
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                    
                    // Spacer for Bottom Navigation Bar & FAB
                    Spacer().frame(height: 120)
                }
            }
            .scrollIndicators(.hidden)
            
            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        if localHabits.count >= 5 && !appSettings.isPremium {
                            showPaywall = true
                        } else {
                            navigateToAddHabit = true
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(DS.primary)
                                .frame(width: 56, height: 56)
                                .shadow(color: DS.primary.opacity(0.3), radius: 20, x: 0, y: 10)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, DS.spacingL)
                    .padding(.bottom, 16)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $navigateToAddHabit) {
            HabitDetailView(habit: nil)
        }
        .sheet(item: $editingHabit) { habit in
            HabitDetailView(habit: habit)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            localHabits = habits
        }
        .onChange(of: habits) { _, newHabits in
            if draggedHabit == nil {
                localHabits = newHabits
            }
        }
        .background(AmbientBackground())
        .alert("Delete Habit?".tr(appSettings.resolvedLanguage), isPresented: $showDeleteAlert, presenting: habitToDelete) { habit in
            Button("Cancel".tr(appSettings.resolvedLanguage), role: .cancel) {
                habitToDelete = nil
            }
            Button("Delete".tr(appSettings.resolvedLanguage), role: .destructive) {
                deleteHabit(habit)
                habitToDelete = nil
            }
        } message: { _ in
            Text("Data irrecoverable after deletion.".tr(appSettings.resolvedLanguage))
        }
    }
    
    private func deleteHabit(_ habit: Habit) {
        withAnimation {
            NotificationManager.shared.cancelReminder(for: habit)
            if let index = localHabits.firstIndex(of: habit) {
                localHabits.remove(at: index)
            }
            if let checkins = habit.checkins {
                for c in checkins { modelContext.delete(c) }
            }
            if let moods = habit.moodRecords {
                for m in moods { modelContext.delete(m) }
            }
            modelContext.delete(habit)
            try? modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

struct HabitDropDelegate: DropDelegate {
    let item: Habit
    @Binding var habits: [Habit]
    @Binding var draggedHabit: Habit?
    let modelContext: ModelContext
    
    func dropEntered(info: DropInfo) {
        guard let draggedHabit = self.draggedHabit,
              draggedHabit.id != item.id,
              let from = habits.firstIndex(of: draggedHabit),
              let to = habits.firstIndex(of: item) else {
            return
        }
        
        if from != to {
            withAnimation(.default) {
                habits.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        for (index, habit) in habits.enumerated() {
            habit.order = index
        }
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        self.draggedHabit = nil
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

struct HabitListCard: View {
    @EnvironmentObject private var appSettings: AppSettings
    let habit: Habit
    
    private var habitColor: Color { Color(hex: habit.color) }
    
    var body: some View {
        VStack(spacing: DS.spacingM) {
            // Top Row
            HStack(spacing: DS.spacingS) {
                // Icon
                ZStack {
                    Circle()
                        .fill(habitColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: habit.icon)
                        .foregroundColor(habitColor)
                        .font(.system(size: 16))
                }
                
                // Name & Streak
                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DS.onSurface)
                    
                    Text("\(habit.currentStreak) \("Days Streak".tr(appSettings.resolvedLanguage))")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(DS.onSurfaceVariant)
                }
                
                Spacer()
                
                // Right Side: Last 30 Days Count
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(habit.checkinCountLast30Days) \("次".tr(appSettings.resolvedLanguage))")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(habitColor)
                    
                    Text("30 Days".tr(appSettings.resolvedLanguage))
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(DS.onSurfaceVariant)
                }
            }
            
            // Heatmap Grid
            let gridData = habit.last182DaysCheckins
            HStack(spacing: 4) {
                ForEach(0..<26, id: \.self) { weekIndex in
                    VStack(spacing: 4) {
                        ForEach(0..<7, id: \.self) { dayIndex in
                            let index = weekIndex * 7 + dayIndex
                            let isChecked = gridData[index]
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(isChecked ? habitColor : DS.uncheckedPlaceholder)
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(DS.spacingM)
        .background(DS.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}

struct StatBlock: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(DS.onSurface)
            Text(label)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(DS.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(DS.uncheckedPlaceholder)
        .cornerRadius(12)
    }
}
