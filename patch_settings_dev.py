import re

with open('Sources/SettingsView.swift', 'r') as f:
    code = f.read()

target = """                .padding(.bottom, 40)
            }
            .background(DS.bgPrimary)"""

insertion = """                    // Developer Testing
                    SettingsSection(title: "Developer (Test Only)".tr(appSettings.resolvedLanguage)) {
                        Toggle(isOn: $appSettings.isPremium) {
                            Text("Mock Premium Status".tr(appSettings.resolvedLanguage))
                                .labelMd()
                                .foregroundColor(DS.onSurface)
                        }
                        .padding(.horizontal, DS.spacingL)
                        .padding(.vertical, 12)
                        .tint(DS.primary)
                    }

                }
                .padding(.bottom, 40)
            }
            .background(DS.bgPrimary)"""

code = code.replace(target, insertion)

with open('Sources/SettingsView.swift', 'w') as f:
    f.write(code)
