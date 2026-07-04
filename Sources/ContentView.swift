import SwiftUI

enum AppTab: Int, CaseIterable {
    case home = 0
    case habits
    case stats
    case settings
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .habits: return "Habits"
        case .stats: return "Stats"
        case .settings: return "Settings"
        }
    }
    
    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .habits: return "checkmark.circle.fill"
        case .stats: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @State private var selection: AppTab = .home
    @State private var showingSettings = false
    @Namespace private var animation
    
    var body: some View {
        let proxySelection = Binding<AppTab>(
            get: { selection },
            set: { newValue in
                if newValue == .settings {
                    showingSettings = true
                } else {
                    selection = newValue
                }
            }
        )
        
        NavigationStack {
            TabView(selection: proxySelection) {
                Tab(AppTab.home.title.tr(appSettings.resolvedLanguage), systemImage: AppTab.home.iconName, value: .home) {
                    HomeView()
                }
                
                Tab(AppTab.habits.title.tr(appSettings.resolvedLanguage), systemImage: AppTab.habits.iconName, value: .habits) {
                    HabitListView()
                }
                
                Tab(AppTab.stats.title.tr(appSettings.resolvedLanguage), systemImage: AppTab.stats.iconName, value: .stats) {
                    StatisticsView()
                }
                
                Tab(AppTab.settings.title.tr(appSettings.resolvedLanguage), systemImage: AppTab.settings.iconName, value: .settings, role: .search) {
                    Color.clear // Placeholder
                }
            }
            .tabViewStyle(.sidebarAdaptable)
            .tint(DS.primary)
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .presentationDragIndicator(.visible)
            }
            .navigationDestination(for: Habit.self) { habit in
                HabitStatsDetailView(habit: habit)
            }
            .navigationDestination(for: HabitEditRoute.self) { route in
                HabitDetailView(habit: route.habit)
            }
            .navigationDestination(for: HabitMonthRoute.self) { route in
                HabitMonthDetailView(habit: route.habit, year: route.year, month: route.month)
            }
            .navigationDestination(for: String.self) { route in
                if route == "add_habit" {
                    HabitDetailView(habit: nil)
                } else if route == "archived_habits" {
                    ArchivedHabitsView()
                }
            }
        }
    }
}
