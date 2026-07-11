import re

with open('Sources/LittleHabitWidget/LittleHabitWidget.swift', 'r') as f:
    code = f.read()

# Fix 1: App Theme logic for widgets
theme_logic = """struct MyWidgetBackground: View {
    @Environment(\\.colorScheme) var systemColorScheme
    var body: some View {
        let appTheme = UserDefaults(suiteName: "group.com.littlehabit.tracker")?.string(forKey: "themeMode") ?? "system"
        let isDark = appTheme == "dark" || (appTheme == "system" && systemColorScheme == .dark)
        isDark ? Color(hex: "#1C1C1E") : Color(hex: "#F9FAFC")
    }
}"""
code = re.sub(r'struct MyWidgetBackground: View \{.*?\n\}', theme_logic, code, flags=re.DOTALL)

# Also fix the text colors inside widget based on the same logic so they force adapt?
# No, if the widget background forces dark but the system is light, Color.primary stays black (because the widget environment colorScheme is light).
# We MUST force the colorScheme on the entire widget configuration body!
# Wait! Can we inject `.environment(\\.colorScheme, ...)` onto the widget view?
# Yes! `MultiHabitCheckinWidgetView(entry: entry).environment(\\.colorScheme, getWidgetColorScheme())`
