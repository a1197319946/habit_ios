import SwiftUI
import WidgetKit

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
    @Environment(\.scenePhase) private var scenePhase
    @State private var selection: AppTab = .home
    @State private var showingSettings = false
    @State private var showLaunchScreen = true
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
            ZStack {
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
                
                if showLaunchScreen {
                    LaunchScreenView(isPresented: $showLaunchScreen)
                        .transition(.opacity.combined(with: .scale(scale: 1.05)))
                        .zIndex(1000)
                }
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
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                getAppGroupModelContainer().mainContext.rollback()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
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

struct LaunchScreenView: View {
    @Binding var isPresented: Bool
    @State private var bgScale: CGFloat = 1.0
    @State private var logoScale: CGFloat = 1.0
    @State private var logoOpacity: Double = 1.0
    @State private var logoOffset: CGFloat = 0
    @State private var sloganOpacity: Double = 1.0
    @State private var sloganOffset: CGFloat = 0
    @State private var loadingProgress: CGFloat = 0.05
    @State private var contentBlur: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            Image("launch_bg")
            // Or use native_launch if preferred, but separate overlay allows clean staggered floating out
                .resizable()
                .scaledToFill()
                .scaleEffect(bgScale)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Spacer()
                
                // Brand Logo & Identifier with dynamic breathing animation
                VStack(spacing: 14) {
                    Image("app_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 88, height: 88)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: Color.black.opacity(0.14), radius: 18, x: 0, y: 8)
                    
                    Text("TickDay小习惯打卡")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "2D3142"))
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                .offset(y: logoOffset)
                
                // Slogan
                Text("小小坚持，大大改变")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "5A5E73").opacity(0.88))
                    .tracking(3.5)
                    .opacity(sloganOpacity)
                    .offset(y: sloganOffset)
                
                Spacer()
                
                // Premium dynamic loading indicator
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(hex: "2D3142").opacity(0.08))
                        .frame(width: 120, height: 3.5)
                    Capsule()
                        .fill(LinearGradient(colors: [Color(hex: "9F7AEA"), Color(hex: "ED64A6")], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 120 * loadingProgress, height: 3.5)
                }
                .padding(.bottom, 54)
                .opacity(sloganOpacity)
                .offset(y: sloganOffset)
            }
            .blur(radius: contentBlur)
        }
        .onAppear {
            // 1. Subtle breathing zoom and silky loading bar fill
            withAnimation(.easeInOut(duration: 1.1)) {
                bgScale = 1.03
            }
            withAnimation(.easeInOut(duration: 0.35)) {
                logoScale = 1.03
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    logoScale = 1.0
                }
            }
            withAnimation(.easeInOut(duration: 0.7)) {
                loadingProgress = 1.0
            }
            
            // 2. Elegant upward float and dissolve out animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                withAnimation(.easeInOut(duration: 0.38)) {
                    logoOffset = -22
                    sloganOffset = -22
                    logoOpacity = 0.0
                    sloganOpacity = 0.0
                    contentBlur = 4.0
                }
            }
            
            // 3. Smooth exit into Home screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPresented = false
                }
            }
        }
    }
}

