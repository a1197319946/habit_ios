import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAboutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.spacingXL) {
                    
                    // ── Menu List Card ──
                    VStack(spacing: 0) {
                        ProfileMenuRow(icon: "clock", iconColor: DS.secondary, label: "Mood History".tr(appSettings.resolvedLanguage)) {
                            // Can route to Mood History
                        }
                        
                        Divider().background(DS.outlineVariant.opacity(0.2)).padding(.horizontal, DS.spacingL)
                        
                        HStack(spacing: DS.spacingM) {
                            ZStack {
                                Circle()
                                    .fill(DS.tertiary.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "globe")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(DS.tertiary)
                            }
                            
                            Text("Language".tr(appSettings.resolvedLanguage))
                                .labelMd()
                                .foregroundColor(DS.onSurface)
                            
                            Spacer()
                            
                            Menu {
                                Picker("", selection: $appSettings.language) {
                                    ForEach(AppLanguage.allCases) { lang in
                                        Text(lang.displayName).tag(lang)
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(appSettings.language.displayName)
                                        .labelMd()
                                        .foregroundColor(DS.onSurfaceVariant)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundColor(DS.onSurfaceVariant)
                                }
                            }
                        }
                        .padding(.horizontal, DS.spacingL)
                        .padding(.vertical, 8)
                        
                        Divider().background(DS.outlineVariant.opacity(0.2)).padding(.horizontal, DS.spacingL)
                        
                        // Theme Color Picker
                        VStack(alignment: .leading, spacing: DS.spacingM) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(DS.primary.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "paintpalette")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(DS.primary)
                                }
                                Text("Theme Color".tr(appSettings.resolvedLanguage))
                                    .labelMd()
                                    .foregroundColor(DS.onSurface)
                                Spacer()
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    let colors = [
                                        "#5e4dbb", // Default Purple
                                        "#2a6951", // Mint Green
                                        "#4A90E2", // Ocean Blue
                                        "#F5A623", // Sunset Orange
                                        "#D0021B", // Ruby Red
                                        "#8B572A", // Earth Brown
                                        "#F8E71C", // Lemon Yellow
                                        "#BD10E0", // Magenta
                                        "#50E3C2", // Cyan
                                        "#4A4A4A"  // Obsidian
                                    ]
                                    ForEach(colors, id: \.self) { hex in
                                        Circle()
                                            .fill(Color(hex: hex))
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: appSettings.themeColorHex == hex ? 3 : 0)
                                            )
                                            .shadow(color: Color(hex: hex).opacity(0.4), radius: appSettings.themeColorHex == hex ? 6 : 0)
                                            .scaleEffect(appSettings.themeColorHex == hex ? 1.1 : 1.0)
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                    appSettings.themeColorHex = hex
                                                }
                                            }
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 4)
                            }
                        }
                        .padding(.horizontal, DS.spacingL)
                        .padding(.vertical, 8)
                        
                        Divider().background(DS.outlineVariant.opacity(0.2)).padding(.horizontal, DS.spacingL)
                        
                        ProfileMenuRow(icon: "square.and.arrow.up", iconColor: DS.primary, label: "Share with Friends".tr(appSettings.resolvedLanguage)) {
                            shareApp()
                        }
                        
                        Divider().background(DS.outlineVariant.opacity(0.2)).padding(.horizontal, DS.spacingL)
                        
                        ProfileMenuRow(icon: "info.circle", iconColor: DS.onSurfaceVariant, label: "About".tr(appSettings.resolvedLanguage)) {
                            showAboutAlert = true
                        }
                        
                        Divider().background(DS.outlineVariant.opacity(0.2)).padding(.horizontal, DS.spacingL)
                        
                        ProfileMenuRow(icon: "questionmark.circle", iconColor: DS.onSurfaceVariant, label: "Contact Support".tr(appSettings.resolvedLanguage)) {}
                    }
                    .background(
                        Color.white.opacity(0.7)
                    )
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .shadow(color: DS.primary.opacity(0.08), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, DS.spacingL)
                    .padding(.top, DS.spacingM)
                    
                }
            }
            .background(AmbientBackground())
            .navigationTitle("Settings".tr(appSettings.resolvedLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("关闭")
                            .foregroundColor(DS.primary)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            .alert("About Bloom", isPresented: $showAboutAlert) {
                Button("OK") {}
            } message: {
                Text("Bloom helps you build better habits.\nVersion 1.0.0")
            }
        }
    }
    
    private func shareApp() {
        let text = "I am using Bloom to build better habits!"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = window
            rootVC.present(activityVC, animated: true)
        }
    }
}

struct ProfileMenuRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.spacingM) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(iconColor)
                }
                
                Text(label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DS.onSurface)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DS.onSurfaceVariant.opacity(0.5))
            }
            .padding(.horizontal, DS.spacingL)
            .padding(.vertical, 8)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
