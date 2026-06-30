import SwiftUI
import SwiftData

struct HabitListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.order) private var habits: [Habit]
    
    @State private var showingAddSheet = false
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            ZStack {
                DS.bgPrimary.edgesIgnoringSafeArea(.all)
                
                if habits.isEmpty {
                    VStack(spacing: DS.spacingL) {
                        Image(systemName: "text.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(DS.textTertiary)
                        Text("还没有习惯")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(DS.textPrimary)
                        Text("点击下方按钮添加你的第一个习惯")
                            .font(.system(size: 15))
                            .foregroundColor(DS.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, DS.spacingXL)
                } else {
                    List {
                        ForEach(habits) { habit in
                            ZStack {
                                NavigationLink(destination: HabitDetailView(habit: habit)) {
                                    EmptyView()
                                }
                                .opacity(0)
                                
                                HStack(spacing: DS.spacingM) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: DS.cornerSmall)
                                            .fill(Color(hex: habit.color).opacity(0.15))
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: habit.icon)
                                            .foregroundColor(Color(hex: habit.color))
                                            .font(.system(size: 20, weight: .medium))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(habit.name)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(DS.textPrimary)
                                        Text(goalSummary(habit))
                                            .font(.system(size: 13))
                                            .foregroundColor(DS.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(DS.textTertiary)
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .padding(.vertical, DS.spacingS)
                            }
                            .listRowBackground(DS.bgCard)
                            .listRowSeparatorTint(DS.border)
                            .listRowInsets(EdgeInsets(top: 4, leading: DS.spacingL, bottom: 4, trailing: DS.spacingL))
                        }
                        .onDelete(perform: deleteHabits)
                        .onMove(perform: moveHabits)
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
                }
                
                // Bottom Button
                VStack {
                    Spacer()
                    Button(action: { showingAddSheet = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                            Text("添加习惯")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(DS.accent)
                        .cornerRadius(DS.cornerPill)
                        .padding(.horizontal, DS.spacingXL)
                        .shadow(color: DS.accent.opacity(0.3), radius: 12, x: 0, y: 6)
                    }
                    .padding(.bottom, 30)
                    .background(
                        LinearGradient(
                            colors: [DS.bgPrimary.opacity(0), DS.bgPrimary],
                            startPoint: .top, endPoint: .bottom
                        )
                        .frame(height: 100)
                        .allowsHitTesting(false)
                    )
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            .navigationTitle("管理习惯")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                EditButton()
                    .foregroundColor(DS.accent)
            }
            .environment(\.editMode, $editMode)
            .sheet(isPresented: $showingAddSheet) {
                NavigationView {
                    HabitDetailView(habit: nil)
                }
            }
        }
    }
    
    private func goalSummary(_ habit: Habit) -> String {
        let period = habit.frequencyType == "weekly" ? "每周" : "每月"
        if habit.goalType == "amount" {
            return "\(period) \(Int(habit.amountValue)) \(habit.amountUnit)"
        } else {
            let target = habit.frequencyType == "weekly" ? habit.weeklyTarget : habit.monthlyTarget
            return "\(period) \(target) 次"
        }
    }
    
    private func deleteHabits(offsets: IndexSet) {
        withAnimation {
            for index in offsets { modelContext.delete(habits[index]) }
        }
    }
    
    private func moveHabits(from source: IndexSet, to destination: Int) {
        var revisedItems: [Habit] = habits.map { $0 }
        revisedItems.move(fromOffsets: source, toOffset: destination)
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
            revisedItems[reverseIndex].order = reverseIndex
        }
    }
}
