import SwiftUI
import CoreData
import WidgetKit
import UniformTypeIdentifiers

struct HabitListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var appSettings: AppSettings
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.order, ascending: true)],
        predicate: NSPredicate(format: "isArchived == NO")
    ) private var habits: FetchedResults<Habit>
    
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
                    headerView
                    
                    // Habit List
                    if localHabits.isEmpty {
                        EmptyHabitsView(onAction: nil)
                            .padding(.top, 100)
                            .padding(.horizontal, 16)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(localHabits) { habit in
                                habitRow(for: habit)
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
            fabView
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
            localHabits = habits.filter { !$0.isArchived }
        }
        .onChange(of: Array(habits)) { newHabits in
            if draggedHabit == nil {
                localHabits = newHabits.filter { !$0.isArchived }
            }
        }
        .background(AmbientBackground())
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Habit?".tr(appSettings.resolvedLanguage)),
                message: Text("Data irrecoverable after deletion.".tr(appSettings.resolvedLanguage)),
                primaryButton: .destructive(Text("Delete".tr(appSettings.resolvedLanguage))) {
                    if let habit = habitToDelete {
                        deleteHabit(habit)
                    }
                    habitToDelete = nil
                },
                secondaryButton: .cancel(Text("Cancel".tr(appSettings.resolvedLanguage))) {
                    habitToDelete = nil
                }
            )
        }
    }
    
    private func deleteHabit(_ habit: Habit) {
        withAnimation {
            NotificationManager.shared.cancelReminder(for: habit)
            if let index = localHabits.firstIndex(of: habit) {
                localHabits.remove(at: index)
            }
            if let checkins = habit.checkins?.allObjects as? [Checkin] {
                for c in checkins { viewContext.delete(c) }
            }
            if let moods = habit.moodRecords?.allObjects as? [MoodRecord] {
                for m in moods { viewContext.delete(m) }
            }
            viewContext.delete(habit)
            try? viewContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Habit".tr(appSettings.resolvedLanguage))
                    .display()
                    .foregroundColor(DS.primary)
                HStack(spacing: 0) {
                    Text("You have ".tr(appSettings.resolvedLanguage))
                        .bodyLg()
                        .foregroundColor(DS.onSurfaceVariant)
                    Text("\(habits.count)")
                        .bodyLg()
                        .foregroundColor(DS.primary)
                        .bold()
                    Text(" habits.".tr(appSettings.resolvedLanguage))
                        .bodyLg()
                        .foregroundColor(DS.onSurfaceVariant)
                }
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
    }

    @ViewBuilder
    private func habitRow(for habit: Habit) -> some View {
        NavigationLink(value: habit) {
            HabitListCard(habit: habit)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            habitContextMenu(for: habit)
        }
        .onDrag {
            self.draggedHabit = habit
            return NSItemProvider(object: habit.id as NSString)
        }
        .onDrop(of: [UTType.text], delegate: HabitDropDelegate(item: habit, habits: $localHabits, draggedHabit: $draggedHabit, viewContext: viewContext))
    }
    
    @ViewBuilder
    private func habitContextMenu(for habit: Habit) -> some View {
        Button(action: { editingHabit = habit }) {
            Label("Edit".tr(appSettings.resolvedLanguage), systemImage: "pencil")
        }
        Button(action: {
            withAnimation {
                NotificationManager.shared.cancelReminder(for: habit)
                habit.isArchived = true
                if let idx = localHabits.firstIndex(of: habit) {
                    localHabits.remove(at: idx)
                }
                try? viewContext.save()
            }
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
    
    @ViewBuilder
    private var fabView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    navigateToAddHabit = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            LinearGradient(
                                colors: [DS.primary, DS.primary.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: DS.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 30)
            }
        }
    }
}

struct HabitDropDelegate: DropDelegate {
    let item: Habit
    @Binding var habits: [Habit]
    @Binding var draggedHabit: Habit?
    let viewContext: NSManagedObjectContext
    
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
        try? viewContext.save()
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
                        .frame(width: 44, height: 44)
                    Image(systemName: habit.icon)
                        .foregroundColor(habitColor)
                        .font(.system(size: 20))
                }
                
                // Name & Streak
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DS.onSurface)
                    
                    Text("\(habit.currentStreak) \("Days Streak".tr(appSettings.resolvedLanguage))")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(DS.onSurfaceVariant)
                }
                
                Spacer()
                
                // Right Side: Last 30 Days Count
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(habit.checkinCountLast30Days) \("次".tr(appSettings.resolvedLanguage))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(habitColor)
                    
                    Text("30 Days".tr(appSettings.resolvedLanguage))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(DS.onSurfaceVariant)
                }
            }
            
            // Heatmap Grid
            let gridData = habit.last182DaysCheckins
            HStack(spacing: 3) {
                ForEach(0..<26, id: \.self) { weekIndex in
                    VStack(spacing: 3) {
                        ForEach(0..<7, id: \.self) { dayIndex in
                            let index = weekIndex * 7 + dayIndex
                            let isChecked = gridData[index]
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(isChecked ? habitColor : DS.uncheckedPlaceholder)
                                .frame(width: 7, height: 7)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(DS.spacingM)
        .background(DS.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

struct StatBlock: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(DS.onSurface)
            Text(label)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(DS.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(DS.uncheckedPlaceholder)
        .cornerRadius(8)
    }
}
