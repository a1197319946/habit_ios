import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Label("打卡", systemImage: "checkmark.circle.fill")
                }
                .tag(0)
            
            HabitListView()
                .tabItem {
                    Label("习惯", systemImage: "list.bullet")
                }
                .tag(1)
            
            StatisticsView()
                .tabItem {
                    Label("统计", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(Color(hex: "8B5CF6"))
    }
}


