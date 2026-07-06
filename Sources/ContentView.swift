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
        
        AppLockView {
            TabView(selection: proxySelection) {
                Tab(AppTab.home.title.tr(appSettings.resolvedLanguage), systemImage: AppTab.home.iconName, value: .home) {
                    TabNavStack {
                        HomeView(selectedTab: proxySelection)
                    }
                }
                
                Tab(AppTab.habits.title.tr(appSettings.resolvedLanguage), systemImage: AppTab.habits.iconName, value: .habits) {
                    TabNavStack {
                        HabitListView()
                    }
                }
                
                Tab(AppTab.stats.title.tr(appSettings.resolvedLanguage), systemImage: AppTab.stats.iconName, value: .stats) {
                    TabNavStack {
                        StatisticsView()
                    }
                }
                
                Tab(AppTab.settings.title.tr(appSettings.resolvedLanguage), systemImage: AppTab.settings.iconName, value: .settings, role: .search) {
                    Color.clear // Placeholder
                }
            }
            .tint(DS.primary)
            .onAppear {
                appSettings.applyTheme()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $appSettings.showPaywall) {
            PaywallView()
                .presentationDragIndicator(.visible)
        }
        .overlay {
            if appSettings.showRetentionOffer {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            appSettings.showRetentionOffer = false
                        }
                    
                    RetentionOfferSheet()
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: appSettings.showRetentionOffer)
    }
}

struct RetentionOfferSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appSettings: AppSettings
    var onDecline: (() -> Void)? = nil
    var onAccept: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: DS.spacingL) {
                
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color(hex: "FDEB71"), Color(hex: "F8D800")], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                        .shadow(color: Color(hex: "F8D800").opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                
                Text("Limited Time Offer".tr(appSettings.resolvedLanguage))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "D4AF37"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color(hex: "D4AF37").opacity(0.15))
                    .cornerRadius(8)
                    .padding(.bottom, -10)
                
                Text("Wait, a special offer!".tr(appSettings.resolvedLanguage))
                    .font(.system(size: 24, weight: .heavy))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(DS.onSurface)
                
                VStack(spacing: DS.spacingS) {
                    Text("15 天免费试用".tr(appSettings.resolvedLanguage))
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(Color(hex: "D4AF37"))
                    
                    Text("试用期间可以随时取消，不扣费".tr(appSettings.resolvedLanguage))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(DS.onSurfaceVariant)
                }
                .padding(.horizontal, DS.spacingL)
                .multilineTextAlignment(.center)
                
                VStack(spacing: DS.spacingM) {
                    Button(action: {
                        appSettings.showRetentionOffer = false
                        if let onAccept = onAccept {
                            onAccept()
                        } else if onDecline == nil {
                            // Being presented from ContentView, so open Paywall
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                appSettings.showPaywall = true
                            }
                        }
                    }) {
                        Text("Start Free Trial".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(LinearGradient(colors: [Color(hex: "F4D03F"), Color(hex: "D4AF37")], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(DS.cornerPill)
                            .shadow(color: Color(hex: "D4AF37").opacity(0.4), radius: 10, y: 5)
                    }
                    Button(action: { 
                        appSettings.showRetentionOffer = false
                        onDecline?()
                    }) {
                        Text("No, thanks".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DS.onSurfaceVariant)
                    }
                }
                .padding(.bottom, 24)
        }
        .padding(.horizontal, DS.spacingM)
        .padding(.top, 32)
        .background(DS.bgPrimary)
        .cornerRadius(32)
        .shadow(color: Color.black.opacity(0.15), radius: 20, y: 10)
        .onAppear {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
}

struct TabNavStack<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        NavigationStack {
            content()
                .toolbar(.visible, for: .tabBar)
                .navigationDestination(for: Habit.self) { habit in
                    HabitStatsDetailView(habit: habit)
                }
                .navigationDestination(for: String.self) { value in
                    if value == "archived_habits" {
                        ArchivedHabitsView()
                    }
                }
                .navigationDestination(for: HabitMonthRoute.self) { route in
                    HabitMonthDetailView(habit: route.habit, year: route.year, month: route.month)
                }
        }
    }
}

