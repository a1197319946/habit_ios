import SwiftUI
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
    @State private var toastMessage: String? = nil
    
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
                    Text("Premium Member".tr(appSettings.resolvedLanguage))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DS.onSurface)
                    Text("All features unlocked".tr(appSettings.resolvedLanguage))
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
            .padding(.horizontal, 20)
            .padding(.top, DS.spacingS)
        }
    }
    
    @ViewBuilder private var featuresSection: some View {
        SettingsSection(title: "Features".tr(appSettings.resolvedLanguage)) {
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
        }
    }
    
    @ViewBuilder private var aboutSection: some View {
        SettingsSection(title: "About".tr(appSettings.resolvedLanguage)) {
            Button {
                // Dummy Action
            } label: {
                SettingsRowLabel(icon: "doc.text", color: .gray, title: "Terms of Service".tr(appSettings.resolvedLanguage), value: "", isPremiumFeature: false, isPremiumUser: true)
            }
            
            Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, 20)
            
            Button {
                // Dummy Action
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
        }
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
