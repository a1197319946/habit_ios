import re

new_settings = """import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.spacingXL) {
                    
                    // ── Menu List Card ──
                    VStack(spacing: 0) {
                        
                        // Language
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
                        .padding(.vertical, 12)
                        
                        Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, DS.spacingL)
                        
                        // Theme Mode
                        HStack(spacing: DS.spacingM) {
                            ZStack {
                                Circle()
                                    .fill(DS.primary.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "moon.stars")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(DS.primary)
                            }
                            
                            Text("Appearance".tr(appSettings.resolvedLanguage))
                                .labelMd()
                                .foregroundColor(DS.onSurface)
                            
                            Spacer()
                            
                            Menu {
                                Picker("", selection: $appSettings.themeMode) {
                                    ForEach(AppTheme.allCases) { theme in
                                        Text(theme.displayName(in: appSettings.resolvedLanguage)).tag(theme)
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(appSettings.themeMode.displayName(in: appSettings.resolvedLanguage))
                                        .labelMd()
                                        .foregroundColor(DS.onSurfaceVariant)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundColor(DS.onSurfaceVariant)
                                }
                            }
                        }
                        .padding(.horizontal, DS.spacingL)
                        .padding(.vertical, 12)
                        
                        Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, DS.spacingL)
                        
                        // Start of Week
                        HStack(spacing: DS.spacingM) {
                            ZStack {
                                Circle()
                                    .fill(DS.secondary.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "calendar")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(DS.secondary)
                            }
                            
                            Text("Start of Week".tr(appSettings.resolvedLanguage))
                                .labelMd()
                                .foregroundColor(DS.onSurface)
                            
                            Spacer()
                            
                            Menu {
                                Picker("", selection: $appSettings.firstWeekday) {
                                    Text("Monday".tr(appSettings.resolvedLanguage)).tag(2)
                                    Text("Sunday".tr(appSettings.resolvedLanguage)).tag(1)
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(appSettings.firstWeekday == 2 ? "Monday".tr(appSettings.resolvedLanguage) : "Sunday".tr(appSettings.resolvedLanguage))
                                        .labelMd()
                                        .foregroundColor(DS.onSurfaceVariant)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.system(size: 12))
                                        .foregroundColor(DS.onSurfaceVariant)
                                }
                            }
                        }
                        .padding(.horizontal, DS.spacingL)
                        .padding(.vertical, 12)
                        
                        Divider().background(DS.outlineVariant.opacity(0.5)).padding(.horizontal, DS.spacingL)
                        
                        // Theme Color Picker
                        VStack(alignment: .leading, spacing: DS.spacingM) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(DS.accent.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "paintpalette")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(DS.accent)
                                }
                                Text("Theme Color".tr(appSettings.resolvedLanguage))
                                    .labelMd()
                                    .foregroundColor(DS.onSurface)
                                Spacer()
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    let colors = [
                                        "#6B5B95", // Primary Purple
                                        "#2E8B57", // Forest Green
                                        "#4169E1", // Deep Blue
                                        "#E07A5F", // Soft Orange
                                        "#D72638", // Ruby Red
                                        "#8D6E63", // Mocha Brown
                                        "#F4A261", // Golden Yellow
                                        "#607D8B", // Slate Gray
                                        "#2A9D8F", // Teal
                                        "#F28482"  // Coral
                                    ]
                                    ForEach(colors, id: \\.self) { hex in
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
                        .padding(.vertical, 12)
                    }
                    .background(
                        DS.surface.opacity(0.7)
                    )
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(DS.outlineVariant, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, DS.spacingL)
                    .padding(.top, DS.spacingM)
                    
                }
            }
            .background(DS.bgPrimary)
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
        }
    }
}
"""
with open('Sources/SettingsView.swift', 'w') as f:
    f.write(new_settings)

