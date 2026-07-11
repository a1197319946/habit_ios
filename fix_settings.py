with open('Sources/SettingsView.swift', 'r') as f:
    code = f.read()

# Fix 1: language
old_lang = """                                Picker("", selection: $appSettings.language) {
                                    ForEach(AppLanguage.allCases) { lang in
                                        Text(lang.displayName).tag(lang)
                                    }
                                }"""
new_lang = """                                Picker("", selection: $appSettings.language) {
                                    ForEach(AppLanguage.allCases) { lang in
                                        Text(lang.displayName).tag(lang)
                                    }
                                }
                                .onChange(of: appSettings.language) { _ in appSettings.objectWillChange.send() }"""
code = code.replace(old_lang, new_lang)

# Fix 2: themeMode
old_theme = """                                .onChange(of: appSettings.themeMode) { _ in
                                    WidgetCenter.shared.reloadAllTimelines()
                                }"""
new_theme = """                                .onChange(of: appSettings.themeMode) { _ in
                                    appSettings.objectWillChange.send()
                                    WidgetCenter.shared.reloadAllTimelines()
                                }"""
code = code.replace(old_theme, new_theme)

# Fix 3: firstWeekday
old_week = """                                Picker("", selection: $appSettings.firstWeekday) {
                                    Text("Monday".tr(appSettings.resolvedLanguage)).tag(2)
                                    Text("Sunday".tr(appSettings.resolvedLanguage)).tag(1)
                                }"""
new_week = """                                Picker("", selection: $appSettings.firstWeekday) {
                                    Text("Monday".tr(appSettings.resolvedLanguage)).tag(2)
                                    Text("Sunday".tr(appSettings.resolvedLanguage)).tag(1)
                                }
                                .onChange(of: appSettings.firstWeekday) { _ in appSettings.objectWillChange.send() }"""
code = code.replace(old_week, new_week)

# Fix 4: themeColorHex
old_color = """                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                    appSettings.themeColorHex = hex
                                                }"""
new_color = """                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                    appSettings.themeColorHex = hex
                                                    appSettings.objectWillChange.send()
                                                }"""
code = code.replace(old_color, new_color)

with open('Sources/SettingsView.swift', 'w') as f:
    f.write(code)

