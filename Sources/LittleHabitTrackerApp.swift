import SwiftUI
import CoreData


enum AppTheme: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var id: String { self.rawValue }
    
    func displayName(in language: AppLanguage) -> String {
        switch self {
        case .system: return L10n.system.tr(language)
        case .light: return L10n.light.tr(language)
        case .dark: return L10n.dark.tr(language)
        }
    }
}

class AppSettings: ObservableObject {
    @AppStorage("isPremium", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var isPremium: Bool = false
    @AppStorage("appLockEnabled", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var appLockEnabled: Bool = false
    @AppStorage("iCloudSyncEnabled", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var iCloudSyncEnabled: Bool = false
    
    @Published var showPaywall: Bool = false
    @Published var showPaywallFromSettings: Bool = false
    @Published var showRetentionOffer: Bool = false
    @Published var openCheckinHabitId: String? = nil
    @AppStorage("hasSeenRetentionOffer", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var hasSeenRetentionOffer: Bool = false

    @AppStorage("appLanguage", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var language: AppLanguage = .system
    @AppStorage("themeColorHex", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var themeColorHex: String = "#5e4dbb"
    @AppStorage("themeMode", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var themeMode: AppTheme = .system
    @AppStorage("firstWeekday", store: UserDefaults(suiteName: "group.com.littlehabit.tracker")) var firstWeekday: Int = 2 // 2 = Monday, 1 = Sunday
    
    
    var colorScheme: ColorScheme? {
        switch themeMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    init() {
        if !isPremium {
            resetPremiumSettingsToDefault()
        }
    }
    
    func resetPremiumSettingsToDefault() {
        objectWillChange.send()
        appLockEnabled = false
        iCloudSyncEnabled = false
        themeColorHex = "#5e4dbb"
        themeMode = .system
        applyTheme()
    }
    
    func applyTheme() {
        DispatchQueue.main.async {
            for scene in UIApplication.shared.connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    for window in windowScene.windows {
                        switch self.themeMode {
                        case .system: window.overrideUserInterfaceStyle = .unspecified
                        case .light: window.overrideUserInterfaceStyle = .light
                        case .dark: window.overrideUserInterfaceStyle = .dark
                        }
                    }
                }
            }
        }
    }

    var locale: Locale? {
        if language == .system {
            return nil
        }
        return Locale(identifier: language.rawValue)
    }
    
    var customCalendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = firstWeekday
        return cal
    }
    
    var resolvedLanguage: AppLanguage {
        if language == .system {
            if let firstLang = Locale.preferredLanguages.first {
                if firstLang.hasPrefix("zh") { return .chinese }
            }
            return .english
        }
        return language
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

@main
struct LittleHabitTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    @StateObject private var appSettings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
                .environment(\.locale, appSettings.locale ?? Locale.current)
                .preferredColorScheme(appSettings.colorScheme)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

import AppIntents

struct LittleHabitAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: CheckinHabitIntent(habitId: ""),
                phrases: ["Check in habit in \(.applicationName)"],
                shortTitle: "Check in Habit",
                systemImageName: "checkmark.circle.fill"
            )
        ]
    }
}
