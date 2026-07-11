import re

with open('Sources/HomeView.swift', 'r') as f:
    content = f.read()

# Add hideCompleted state
if "@State private var hideCompleted" not in content:
    content = content.replace(
        "@State private var showConfetti = false",
        "@State private var showConfetti = false\n    @State private var hideCompleted = false"
    )

# Add buttons and update ForEach
old_list_start = """                    // List for Habits
                    if habits.isEmpty {"""

new_list_start = """                    // List for Habits
                    if habits.isEmpty {"""

# Replace spacing and ForEach
old_list_code = """                        LazyVStack(spacing: DS.spacingM) {
                            ForEach(habits) { habit in"""

new_list_code = """                        // Top Actions
                        HStack {
                            Button(action: {
                                withAnimation { hideCompleted.toggle() }
                            }) {
                                Text(hideCompleted ? "显示已打卡" : "隐藏已打卡")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(DS.onSurfaceVariant)
                            }
                            
                            Spacer()
                            
                            NavigationLink(destination: HabitListView()) {
                                Text("管理习惯 >")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(DS.primary)
                            }
                        }
                        .padding(.horizontal, DS.spacingL)
                        .padding(.bottom, 4)
                        
                        LazyVStack(spacing: 12) {
                            let visibleHabits = habits.filter { habit in
                                if hideCompleted {
                                    return !isHabitChecked(habit: habit)
                                }
                                return true
                            }
                            ForEach(visibleHabits) { habit in"""

if "管理习惯 >" not in content:
    content = content.replace(old_list_code, new_list_code)

with open('Sources/HomeView.swift', 'w') as f:
    f.write(content)
