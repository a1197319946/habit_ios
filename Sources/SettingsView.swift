import SwiftUI
import SwiftData
import WidgetKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showingExport = false
    @State private var showingImport = false
    @State private var exportURL: URL?
    @State private var showingWidgetGuide = false
    @State private var showingWidgetDiagnostic = false
    @State private var toastMessage: String? = nil
    @ObservedObject private var cloudSyncManager = CloudSyncManager.shared
    @ObservedObject private var storeManager = StoreManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    bannerSection
                    featuresSection
                    appearanceSection
                    languageSection
                    appLockSection
                    dataSection
                    aboutSection
                    developerSection
                }
                .padding(.bottom, 40)
            }
            .background(AmbientBackground())
            .navigationTitle("Settings".tr(appSettings.resolvedLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Close".tr(appSettings.resolvedLanguage))
                            .foregroundColor(DS.primary)
                            .font(.system(size: 15, weight: .medium))
                    }
                }
            }
            .fileExporter(isPresented: $showingExport, document: JSONDocument(url: exportURL), contentType: .commaSeparatedText, defaultFilename: "LittleHabit_Excel_Data") { result in
                switch result {
                case .success(_):
                    withAnimation(.spring()) {
                        toastMessage = "导出成功！".tr(appSettings.resolvedLanguage)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.spring()) {
                            toastMessage = nil
                        }
                    }
                case .failure(let err):
                    print("Export failed: \(err)")
                }
            }
            .fileImporter(isPresented: $showingImport, allowedContentTypes: [.json]) { result in
                switch result {
                case .success(let url):
                    DataBackupManager.shared.importData(from: url, modelContext: modelContext)
                case .failure(let err):
                    print("Import failed: \(err)")
                }
            }
            .overlay(alignment: .bottom) {
                if let message = toastMessage {
                    Text(message)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.85))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .padding(.bottom, 80)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .sheet(isPresented: $appSettings.showPaywallFromSettings) {
            PaywallView()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingWidgetGuide) {
            WidgetGuideSheet()
                .presentationDetents([.fraction(0.55), .medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingWidgetDiagnostic) {
            WidgetDiagnosticSheet()
                .presentationDragIndicator(.visible)
        }
        .preferredColorScheme(appSettings.colorScheme)
    }
    
    @ViewBuilder private var bannerSection: some View {
        if !appSettings.isPremium {
            Button(action: {
                appSettings.showPaywallFromSettings = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Upgrade to Premium".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DS.onSurface)
                        Text("Unlock all features".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(DS.onSurfaceVariant)
                    }
                    Spacer()
                    Image(systemName: "crown.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.yellow)
                }
                .padding(DS.spacingL)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(DS.surface)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.top, DS.spacingS)
        } else {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TickDay 尊享会员".tr(appSettings.resolvedLanguage))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DS.onSurface)
                    Text(storeManager.expirationDateFormatted(in: appSettings.resolvedLanguage))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "D4AF37"))
                }
                Spacer()
                Image(systemName: "crown.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.yellow)
            }
            .padding(DS.spacingL)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(DS.surface)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 20)
            .padding(.top, DS.spacingS)
        }
    }
    
    @ViewBuilder private var featuresSection: some View {
        SettingsSection(title: "Features".tr(appSettings.resolvedLanguage)) {
            Button {
                showingWidgetDiagnostic = true
            } label: {
                SettingsRowLabel(icon: "stethoscope", color: .red, title: "小组件深度诊断与排查".tr(appSettings.resolvedLanguage), value: "点击检查不显示原因".tr(appSettings.resolvedLanguage), isPremiumFeature: false, isPremiumUser: true)
            }
            Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, 20)
            Button {
                showingWidgetGuide = true
            } label: {
                SettingsRowLabel(icon: "squareshape.split.2x2", color: .purple, title: "Widgets".tr(appSettings.resolvedLanguage), value: "Add to Home Screen".tr(appSettings.resolvedLanguage), isPremiumFeature: false, isPremiumUser: true)
            }
        }
    }
    
    @ViewBuilder private var appearanceSection: some View {
        SettingsSection(title: "Appearance".tr(appSettings.resolvedLanguage)) {
            
            // Dark Mode
            if appSettings.isPremium {
                Menu {
                    Picker("", selection: $appSettings.themeMode) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.displayName(in: appSettings.resolvedLanguage)).tag(theme)
                        }
                    }
                    .onChange(of: appSettings.themeMode) { _ in
                        appSettings.applyTheme()
                        appSettings.objectWillChange.send()
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                } label: {
                    SettingsRowLabel(icon: "moon.stars", color: DS.primary, title: "Dark Mode".tr(appSettings.resolvedLanguage), value: appSettings.themeMode.displayName(in: appSettings.resolvedLanguage), isPremiumFeature: false, isPremiumUser: true)
                }
            } else {
                Button { appSettings.showPaywallFromSettings = true } label: {
                    SettingsRowLabel(icon: "moon.stars", color: DS.primary, title: "Dark Mode".tr(appSettings.resolvedLanguage), value: appSettings.themeMode.displayName(in: appSettings.resolvedLanguage), isPremiumFeature: true, isPremiumUser: false)
                }
            }
            
            Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, 20)
            
            // Theme Color Picker
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle().fill(DS.accent.opacity(0.15)).frame(width: 36, height: 36)
                        Image(systemName: "paintpalette").font(.system(size: 16, weight: .semibold)).foregroundColor(DS.accent)
                    }
                    Text("Theme Color".tr(appSettings.resolvedLanguage))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DS.onSurface)
                    Spacer()
                    if !appSettings.isPremium {
                        Image(systemName: "lock.fill").foregroundColor(DS.primary).font(.system(size: 14))
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if !appSettings.isPremium {
                        appSettings.showPaywallFromSettings = true
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        let colors = ["#5e4dbb", "#2E8B57", "#4169E1", "#E07A5F", "#D72638", "#8D6E63", "#F4A261", "#607D8B", "#2A9D8F", "#F28482"]
                        ForEach(colors, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 32, height: 32)
                                .overlay(Circle().stroke(Color.white, lineWidth: appSettings.themeColorHex == hex ? 2.5 : 0))
                                .shadow(color: Color(hex: hex).opacity(0.4), radius: appSettings.themeColorHex == hex ? 5 : 0)
                                .scaleEffect(appSettings.themeColorHex == hex ? 1.15 : 1.0)
                                .zIndex(appSettings.themeColorHex == hex ? 100 : 1)
                                .onTapGesture {
                                    if !appSettings.isPremium {
                                        appSettings.showPaywallFromSettings = true
                                    } else {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            appSettings.themeColorHex = hex
                                            appSettings.objectWillChange.send()
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, 20)
            
            // Start of Week
            Menu {
                Picker("", selection: $appSettings.firstWeekday) {
                    Text("Monday".tr(appSettings.resolvedLanguage)).tag(2)
                    Text("Sunday".tr(appSettings.resolvedLanguage)).tag(1)
                }
                .onChange(of: appSettings.firstWeekday) { _ in appSettings.objectWillChange.send() }
            } label: {
                SettingsRowLabel(icon: "calendar", color: DS.secondary, title: "Start of Week".tr(appSettings.resolvedLanguage), value: appSettings.firstWeekday == 2 ? "Monday".tr(appSettings.resolvedLanguage) : "Sunday".tr(appSettings.resolvedLanguage), isPremiumFeature: false, isPremiumUser: true)
            }
        }
    }
    
    @ViewBuilder private var languageSection: some View {
        SettingsSection(title: "Language".tr(appSettings.resolvedLanguage)) {
            Menu {
                Picker("", selection: $appSettings.language) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .onChange(of: appSettings.language) { _ in appSettings.objectWillChange.send() }
            } label: {
                SettingsRowLabel(icon: "globe", color: DS.tertiary, title: "Language".tr(appSettings.resolvedLanguage), value: appSettings.language.displayName, isPremiumFeature: false, isPremiumUser: true)
            }
        }
    }
    
    @ViewBuilder private var appLockSection: some View {
        SettingsSection(title: "App Lock".tr(appSettings.resolvedLanguage)) {
            SettingsRowToggle(icon: "lock.shield", color: .green, title: "App Lock".tr(appSettings.resolvedLanguage), isOn: appSettings.appLockEnabled, isPremiumFeature: true, isPremiumUser: appSettings.isPremium) {
                if !appSettings.isPremium {
                    appSettings.showPaywallFromSettings = true
                } else {
                    withAnimation { appSettings.appLockEnabled.toggle() }
                }
            }
        }
    }
    
    @ViewBuilder private var dataSection: some View {
        SettingsSection(title: "Data".tr(appSettings.resolvedLanguage)) {
            
            // iCloud Sync
            SettingsRowToggle(icon: "icloud", color: .cyan, title: "iCloud Sync".tr(appSettings.resolvedLanguage), isOn: appSettings.iCloudSyncEnabled, isPremiumFeature: true, isPremiumUser: appSettings.isPremium) {
                if !appSettings.isPremium {
                    appSettings.showPaywallFromSettings = true
                } else {
                    withAnimation { appSettings.iCloudSyncEnabled.toggle() }
                }
            }
            
            if appSettings.iCloudSyncEnabled && appSettings.isPremium {
                Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, 20)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("iCloud 状态".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(DS.onSurfaceVariant)
                        Text(cloudSyncManager.statusMessage.tr(appSettings.resolvedLanguage))
                            .font(.system(size: 13))
                            .foregroundColor(cloudSyncManager.accountStatus == .available ? .green : .orange)
                    }
                    Spacer()
                    Button(action: {
                        cloudSyncManager.statusMessage = "状态检查中..."
                        cloudSyncManager.checkAccountStatus()
                    }) {
                        Text("立即检查同步".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(DS.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(DS.surfaceContainerLow)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            
            Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, 20)
            
            // Import
            Button {
                if !appSettings.isPremium {
                    appSettings.showPaywallFromSettings = true
                } else {
                    showingImport = true
                }
            } label: {
                SettingsRowLabel(icon: "arrow.down.doc", color: .blue, title: "Import Data".tr(appSettings.resolvedLanguage), value: "", isPremiumFeature: true, isPremiumUser: appSettings.isPremium)
            }
            
            Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, 20)
            
            // Export
            Button {
                if !appSettings.isPremium {
                    appSettings.showPaywallFromSettings = true
                } else {
                    if let url = DataBackupManager.shared.exportExcelData(modelContext: modelContext, language: appSettings.resolvedLanguage) {
                        exportURL = url
                        showingExport = true
                    }
                }
            } label: {
                SettingsRowLabel(icon: "arrow.up.doc", color: .pink, title: "Export Data".tr(appSettings.resolvedLanguage), value: "", isPremiumFeature: true, isPremiumUser: appSettings.isPremium)
            }
            
            Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, 20)
            
            Button {
                mockYearlyData()
            } label: {
                HStack {
                    Image(systemName: "wand.and.stars")
                        .foregroundColor(.purple)
                        .font(.system(size: 18))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("一键生成今年模拟打卡数据".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DS.onSurface)
                        Text("为现有习惯随机填充今年打卡与情绪记录".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 12))
                            .foregroundColor(DS.onSurfaceVariant)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DS.onSurfaceVariant)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder private var aboutSection: some View {
        SettingsSection(title: "About".tr(appSettings.resolvedLanguage)) {
            Button {
                if let url = URL(string: "https://a1197319946.github.io/habit_ios/support.html") {
                    UIApplication.shared.open(url)
                }
            } label: {
                SettingsRowLabel(icon: "questionmark.circle", color: .orange, title: "Help & Support".tr(appSettings.resolvedLanguage), value: "", isPremiumFeature: false, isPremiumUser: true)
            }
            
            Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, 20)
            
            Button {
                if let url = URL(string: "https://a1197319946.github.io/habit_ios/privacy.html") {
                    UIApplication.shared.open(url)
                }
            } label: {
                SettingsRowLabel(icon: "hand.raised", color: .gray, title: "Privacy Policy".tr(appSettings.resolvedLanguage), value: "", isPremiumFeature: false, isPremiumUser: true)
            }
        }
    }
    
    @ViewBuilder private var developerSection: some View {
        SettingsSection(title: "Developer (Test Only)".tr(appSettings.resolvedLanguage)) {
            Toggle(isOn: $appSettings.isPremium) {
                Text("Mock Premium Status".tr(appSettings.resolvedLanguage))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DS.onSurface)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .tint(DS.primary)
            
            Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, 20)
            
            Button {
                mockYearlyData()
            } label: {
                HStack {
                    Image(systemName: "wand.and.stars")
                        .foregroundColor(.purple)
                        .font(.system(size: 18))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("一键生成今年模拟打卡数据".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DS.onSurface)
                        Text("为现有习惯随机填充今年打卡与情绪记录".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 12))
                            .foregroundColor(DS.onSurfaceVariant)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DS.onSurfaceVariant)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func mockYearlyData() {
        let descriptor = FetchDescriptor<Habit>()
        guard let habits = try? modelContext.fetch(descriptor) else { return }
        
        var targetHabits = habits
        if targetHabits.isEmpty {
            let h1 = Habit(name: "早起喝水", color: "#3B82F6", icon: "drop.fill")
            h1.goalType = "amount"
            h1.amountValue = 2000
            h1.amountUnit = "ml"
            h1.frequencyType = "daily"
            h1.order = 0
            
            let h2 = Habit(name: "阅读30分钟", color: "#8B5CF6", icon: "book.fill")
            h2.goalType = "frequency"
            h2.frequencyType = "weekly"
            h2.weeklyTarget = 5
            h2.order = 1
            
            let h3 = Habit(name: "慢跑锻炼", color: "#10B981", icon: "figure.run")
            h3.goalType = "amount"
            h3.amountValue = 5.0
            h3.amountUnit = "km"
            h3.frequencyType = "weekly"
            h3.weeklyTarget = 3
            h3.order = 2
            
            let h4 = Habit(name: "冥想放松", color: "#F59E0B", icon: "wind")
            h4.goalType = "frequency"
            h4.frequencyType = "weekly"
            h4.weeklyTarget = 4
            h4.order = 3
            
            modelContext.insert(h1)
            modelContext.insert(h2)
            modelContext.insert(h3)
            modelContext.insert(h4)
            targetHabits = [h1, h2, h3, h4]
        }
        
        let calendar = Calendar.current
        let today = Date()
        let currentYear = calendar.component(.year, from: today)
        
        var components = DateComponents()
        components.year = currentYear
        components.month = 1
        components.day = 1
        guard let startDate = calendar.date(from: components) else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let moodTypes = ["excited", "happy", "normal", "down", "happy", "excited"]
        let moodTexts = [
            "今天状态超棒，轻松完成打卡！",
            "坚持小习惯，生活更规律了～",
            "略微疲惫，但依然完成了目标。",
            "精力充沛，为自己点赞！",
            "平淡真实又充实的一天。"
        ]
        
        for habit in targetHabits {
            let existingDates = habit.checkinDates
            var currentDate = startDate
            
            while currentDate <= today {
                let dateStr = formatter.string(from: currentDate)
                
                if !existingDates.contains(dateStr) {
                    let prob = 0.76 + (Double(habit.order % 3) * 0.06)
                    if Double.random(in: 0...1) < prob {
                        var amt = 1.0
                        if habit.goalType == "amount" && habit.amountValue > 0 {
                            let factor = Double.random(in: 0.7...1.3)
                            amt = (habit.amountValue * factor * 10).rounded() / 10.0
                        }
                        let checkin = Checkin(dateString: dateStr, amount: amt)
                        checkin.timestamp = currentDate
                        checkin.habit = habit
                        modelContext.insert(checkin)
                        
                        if Double.random(in: 0...1) < 0.18 {
                            let moodType = moodTypes.randomElement() ?? "happy"
                            let moodText = moodTexts.randomElement() ?? ""
                            let mood = MoodRecord(type: moodType, text: moodText)
                            mood.timestamp = currentDate
                            mood.habit = habit
                            modelContext.insert(mood)
                        }
                    }
                }
                
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? today.addingTimeInterval(86400)
            }
        }
        
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        
        toastMessage = "已为所有习惯成功生成今年全套模拟打卡与情绪数据！".tr(appSettings.resolvedLanguage)
    }
}

struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json, .commaSeparatedText, .spreadsheet, .data] }
    var url: URL?
    init(url: URL?) { self.url = url }
    init(configuration: ReadConfiguration) throws { }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        if let url = url { return try FileWrapper(url: url, options: .immediate) }
        return FileWrapper(regularFileWithContents: Data())
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(DS.onSurfaceVariant)
                .padding(.horizontal, 20)
                .padding(.leading, 6)
            
            VStack(spacing: 0) {
                content
            }
            .buttonStyle(.plain) // This makes any buttons inside this stack render normally without default button styling, but their touch area is active.
            .background(
                DS.surface.opacity(0.85)
            )
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(DS.outlineVariant, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
            .padding(.horizontal, 20)
        }
    }
}

struct SettingsRowLabel: View {
    let icon: String
    let color: Color
    let title: String
    let value: String
    let isPremiumFeature: Bool
    let isPremiumUser: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 16, weight: .semibold)).foregroundColor(color)
            }
            
            Text(title).font(.system(size: 16, weight: .medium)).foregroundColor(DS.onSurface)
            
            Spacer()
            
            if !value.isEmpty {
                Text(value).font(.system(size: 16, weight: .medium)).foregroundColor(DS.onSurfaceVariant)
            }
            
            if isPremiumFeature && !isPremiumUser {
                Image(systemName: "lock.fill").font(.system(size: 14)).foregroundColor(DS.primary)
            } else {
                Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(DS.onSurfaceVariant.opacity(0.5))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle()) // Makes the whole row touchable
    }
}

struct SettingsRowToggle: View {
    let icon: String
    let color: Color
    let title: String
    let isOn: Bool
    let isPremiumFeature: Bool
    let isPremiumUser: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 16, weight: .semibold)).foregroundColor(color)
            }
            
            Text(title).font(.system(size: 16, weight: .medium)).foregroundColor(DS.onSurface)
            
            Spacer()
            
            if isPremiumFeature && !isPremiumUser {
                Image(systemName: "lock.fill").font(.system(size: 14)).foregroundColor(DS.primary)
            }
            
            Toggle("", isOn: Binding(
                get: { isOn },
                set: { _ in action() }
            ))
            .labelsHidden()
            .tint(DS.primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}


struct WidgetGuideSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appSettings: AppSettings
    
    var body: some View {
        VStack(spacing: DS.spacingL) {
            // Header
            HStack {
                Text("How to add Widgets".tr(appSettings.resolvedLanguage))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(DS.onSurface)
                Spacer()
            }
            .padding(.top, DS.spacingM)
            
            // Steps
            VStack(spacing: DS.spacingM) {
                WidgetGuideStepRow(
                    number: "1",
                    text: "Go to your Home Screen.".tr(appSettings.resolvedLanguage)
                )
                WidgetGuideStepRow(
                    number: "2",
                    text: "Long press any empty space until apps jiggle.".tr(appSettings.resolvedLanguage)
                )
                WidgetGuideStepRow(
                    number: "3",
                    text: "Tap '+' in top left, search 'Little Habit', and tap 'Add Widget'.".tr(appSettings.resolvedLanguage)
                )
                WidgetGuideStepRow(
                    number: "4",
                    text: "Choose your favorite widget size and place it on your Home Screen.".tr(appSettings.resolvedLanguage)
                )
            }
            .padding(DS.spacingM)
            .background(DS.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            Spacer(minLength: 0)
            
            // Bottom Button
            Button(action: { dismiss() }) {
                Text("Got it".tr(appSettings.resolvedLanguage))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(DS.primary)
                    .clipShape(Capsule())
            }
            .padding(.bottom, DS.spacingM)
        }
        .padding(.horizontal, DS.spacingL)
        .padding(.top, DS.spacingM)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}

struct WidgetGuideStepRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: DS.spacingM) {
            Text(number)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(DS.primary)
                .clipShape(Circle())
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(DS.onSurface)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
            
            Spacer()
        }
    }
}

struct WidgetDiagnosticSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var plugInsFound: [String] = []
    @State private var appGroupStatus: String = "检查中..."
    @State private var widgetConfigsCount: String = "读取中..."
    @State private var rawLogs: [String] = []
    @State private var isReloading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("由于 iOS 18 系统缓存或签名策略限制，如果桌面长按添加菜单中搜索不到「TickDay」小组件，请根据下方真机实测诊断信息进行排查：")
                        .font(.system(size: 14))
                        .foregroundColor(DS.onSurfaceVariant)
                        .padding(.horizontal)
                    
                    // Status Cards
                    VStack(spacing: 12) {
                        diagnosticCard(title: "1. 扩展插件打包检测 (PlugIns)", status: plugInsFound.isEmpty ? "❌ 未检测到 .appex (请在 Xcode Clean 后重新构建)" : "✅ 已嵌入: \(plugInsFound.joined(separator: ", "))", color: plugInsFound.isEmpty ? .red : .green)
                        
                        diagnosticCard(title: "2. App Group 容器沙盒权限", status: appGroupStatus, color: appGroupStatus.contains("✅") ? .green : .red)
                        
                        diagnosticCard(title: "3. 当前桌面已添加小组件数量", status: widgetConfigsCount, color: widgetConfigsCount.contains("0 个") || widgetConfigsCount.contains("读取异常") || widgetConfigsCount.contains("读取中") ? .blue : .green)
                    }
                    .padding(.horizontal)
                    
                    // Actions & Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("排查与修复指南：")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(DS.onSurface)
                        
                        if widgetConfigsCount.contains("0 个") || widgetConfigsCount.contains("读取中") || widgetConfigsCount.contains("异常") {
                            Text("ℹ️ **特别释疑 (为什么这里显示 0 个？)**：\nApple 系统的 API (`getCurrentConfigurations`) 返回的是**「您目前已经挂在手机桌面/锁屏上的小组件实例数量」**。当您还没往桌面上添加任何 TickDay 小组件时，这里一定会显示为 0 个，**这是完全正常的现象，绝对不是 Bug！**\n\n👉 **为什么长按「+」号依然搜不到小组件？如何排查？**\n对于 iOS 18 系统，如果通过 Xcode 安装后搜不到小组件，核心原因是系统守护进程 (`chronod`) 没有刷新对当前 App 包 `PlugIns/LittleHabitWidget.appex` 的组件索引。\n\n💡 **请严格按以下步序强制 iOS 系统重新识别：**\n1. 点击下方 **「强制通知系统刷新小组件库」** 按钮；\n2. **关键一步**：请将 iPhone 完全**关机后重启**（iOS 18 在开机启动阶段会强制 `chronod` 扫描所有以开发证书签署的扩展包并重建索引）；\n3. 重启解锁后，打开 App 停留 3 秒，再返回 iPhone 桌面长按空白处 -> 点击左上角「+」-> 搜索 **TickDay** 即可看到！")
                                .font(.system(size: 14))
                                .foregroundColor(DS.onSurface)
                                .lineSpacing(4)
                        } else {
                            Text("🎉 **您的手机桌面上已经成功添加了活跃小组件！**\n您可以在桌面上直接体验习惯打卡与日历功能！")
                                .font(.system(size: 14))
                                .foregroundColor(DS.onSurface)
                                .lineSpacing(4)
                        }
                        
                        Button {
                            isReloading = true
                            WidgetCenter.shared.reloadAllTimelines()
                            for kind in ["LittleHabitWidget", "NewSingleHabitWidget", "SingleMonthWidget", "MultiMonthWidget", "SingleYearlyWidget"] {
                                WidgetCenter.shared.reloadTimelines(ofKind: kind)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                isReloading = false
                                runDiagnostics()
                            }
                        } label: {
                            HStack {
                                if isReloading {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                }
                                Text(isReloading ? "正在强制通知 iOS 系统..." : "强制通知系统刷新小组件库")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(DS.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(DS.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal)
                    
                    // Raw Logs
                    VStack(alignment: .leading, spacing: 8) {
                        Text("系统底层诊断日志 (Diagnostics Log):")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DS.onSurfaceVariant)
                        
                        ScrollView(.horizontal, showsIndicators: true) {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(rawLogs, id: \.self) { log in
                                    Text(log)
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(DS.onSurface)
                                }
                            }
                        }
                        .padding(10)
                        .background(Color.black.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                }
                .padding(.top)
            }
            .navigationTitle("小组件真机自检报告")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
            .onAppear {
                runDiagnostics()
            }
        }
    }
    
    private func diagnosticCard(title: String, status: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DS.onSurfaceVariant)
            Text(status)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    
    private func runDiagnostics() {
        rawLogs.removeAll()
        rawLogs.append("[Start] Diagnostic checks at \(Date())")
        
        // 1. Check PlugIns folder
        if let plugInsPath = Bundle.main.builtInPlugInsURL?.path {
            rawLogs.append("[PlugIns] Path: \(plugInsPath)")
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: plugInsPath)
                rawLogs.append("[PlugIns] Found items: \(files)")
                let appexes = files.filter { $0.hasSuffix(".appex") }
                self.plugInsFound = appexes
            } catch {
                rawLogs.append("[PlugIns] Error reading plugInsPath: \(error)")
                self.plugInsFound = []
            }
        } else {
            rawLogs.append("[PlugIns] builtInPlugInsURL is nil")
            self.plugInsFound = []
        }
        
        // 2. Check App Group
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.littlehabit.tracker") {
            appGroupStatus = "✅ App Group 容器连接成功 (\(groupURL.lastPathComponent))"
            rawLogs.append("[AppGroup] Success: \(groupURL.path)")
        } else {
            appGroupStatus = "❌ 无法连接 group.com.littlehabit.tracker 容器"
            rawLogs.append("[AppGroup] Error: containerURL returned nil")
        }
        
        // 3. Check WidgetKit Configurations
        WidgetCenter.shared.getCurrentConfigurations { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let configs):
                    self.rawLogs.append("[WidgetKit] Configurations found: \(configs.count)")
                    for cfg in configs {
                        self.rawLogs.append(" - Kind: \(cfg.kind), Family: \(cfg.family)")
                    }
                    if configs.isEmpty {
                        self.widgetConfigsCount = "ℹ️ 桌面当前已放置 0 个小组件 (正常)"
                    } else {
                        self.widgetConfigsCount = "✅ 桌面当前已放置 \(configs.count) 个小组件实例"
                    }
                case .failure(let error):
                    self.rawLogs.append("[WidgetKit] Error reading configs: \(error.localizedDescription)")
                    self.widgetConfigsCount = "⚠️ 读取异常: \(error.localizedDescription)"
                }
            }
        }
    }
}
