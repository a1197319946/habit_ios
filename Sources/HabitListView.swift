import SwiftUI
import SwiftData

struct HabitListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.order) private var habits: [Habit]
    
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F5F5F7").edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("共 \(habits.count) 个习惯")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 16)
                    
                    if habits.isEmpty {
                        Spacer()
                        VStack(spacing: 20) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: 80, height: 80)
                                    .shadow(color: Color.black.opacity(0.05), radius: 10)
                                
                                Image(systemName: "flag.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(hex: "#8B5CF6"))
                            }
                            Text("这里空空如也")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        Spacer()
                    } else {
                        List {
                            ForEach(habits) { habit in
                                ZStack {
                                    // Custom NavigationLink that hides the default arrow
                                    NavigationLink(destination: HabitDetailView(habit: habit)) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                    
                                    // Custom Row Content
                                    HStack(spacing: 16) {
                                        Image(systemName: "line.3.horizontal")
                                            .foregroundColor(Color(UIColor.systemGray3))
                                            .font(.system(size: 20))
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(hex: habit.color))
                                                .frame(width: 48, height: 48)
                                                .shadow(color: Color.white.opacity(0.3), radius: 4, x: 0, y: 2) // Inner shadow simulation
                                            
                                            Image(systemName: habit.icon)
                                                .foregroundColor(.white)
                                                .font(.system(size: 20))
                                        }
                                        
                                        Text(habit.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white.opacity(0.8))
                                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                    )
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                            }
                            .onDelete(perform: deleteHabits)
                            .onMove(perform: moveHabits)
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                
                // Fixed Bottom Add Button
                VStack {
                    Spacer()
                    Button(action: { showingAddSheet = true }) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                            Text("添加习惯")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "#8B5CF6"))
                        .foregroundColor(.white)
                        .cornerRadius(26)
                        .shadow(color: Color(hex: "#8B5CF6").opacity(0.4), radius: 10, x: 0, y: 8)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("管理习惯")
            .sheet(isPresented: $showingAddSheet) {
                NavigationView {
                    HabitDetailView(habit: nil)
                }
            }
        }
    }
    
    private func deleteHabits(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(habits[index])
            }
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
