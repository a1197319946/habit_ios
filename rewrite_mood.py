import re

with open('Sources/MoodRecorderView.swift', 'r') as f:
    content = f.read()

# Remove NavigationView and change toolbar to HStack
old_body_start = """    var body: some View {
        NavigationView {
            ZStack {
                AmbientBackground()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DS.spacingXL) {"""
new_body_start = """    var body: some View {
        ZStack {
            AmbientBackground()
            
            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DS.onSurfaceVariant)
                            .font(.system(size: 24))
                    }
                }
                .padding(.horizontal, DS.spacingL)
                .padding(.top, DS.spacingM)
                .padding(.bottom, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DS.spacingL) {"""
content = content.replace(old_body_start, new_body_start)

# Change header text to Chinese
old_header = """                        // Header
                        VStack(alignment: .leading, spacing: DS.spacingS) {
                            Text("Log Your Mood".tr(appSettings.resolvedLanguage))
                                .display()
                                .foregroundColor(DS.primary)
                            Text("How are you feeling right now?".tr(appSettings.resolvedLanguage))
                                .bodyLg()
                                .foregroundColor(DS.onSurfaceVariant)
                        }"""
new_header = """                        // Header
                        VStack(alignment: .leading, spacing: DS.spacingS) {
                            Text("记录心情")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(DS.onSurface)
                            Text("此刻感觉如何？")
                                .font(.system(size: 16))
                                .foregroundColor(DS.onSurfaceVariant)
                        }"""
content = content.replace(old_header, new_header)

# Change text field placeholder
content = content.replace('TextField("Write a note...".tr(appSettings.resolvedLanguage), text: $noteText)', 'TextField("写点什么...", text: $noteText)')

# Change button text
content = content.replace('Text("Save".tr(appSettings.resolvedLanguage))', 'Text("保存")')

# Change "Your Journey" to Chinese
content = content.replace('Text("Your Journey".tr(appSettings.resolvedLanguage))', 'Text("我的旅程")')
content = content.replace('Text("No moments recorded yet.".tr(appSettings.resolvedLanguage))', 'Text("暂无心情记录")')

# Change emoji rendering to sf symbols
old_mood_button = """                                            if selectedMood == mood {
                                                Circle()
                                                    .stroke(DS.primary, lineWidth: 2)
                                                    .frame(width: 48, height: 48)
                                            }
                                            
                                            Text(emoji(for: mood))
                                                .font(.system(size: 26))
                                        }"""
new_mood_button = """                                            if selectedMood == mood {
                                                Circle()
                                                    .stroke(DS.primary, lineWidth: 2)
                                                    .frame(width: 48, height: 48)
                                            }
                                            
                                            Image(systemName: moodIcon(for: mood))
                                                .font(.system(size: 24))
                                                .foregroundColor(moodColor(for: mood))
                                        }"""
content = content.replace(old_mood_button, new_mood_button)

old_timeline_icon = """                    Text(emoji(for: record.type))
                        .font(.system(size: 24))"""
new_timeline_icon = """                    Image(systemName: moodIcon(for: record.type))
                        .font(.system(size: 20))
                        .foregroundColor(moodColor(for: record.type))"""
content = content.replace(old_timeline_icon, new_timeline_icon)

# Replace emoji functions
old_emoji_func = """    private func emoji(for type: String) -> String {
        switch type {
        case "excited": return "🤩"
        case "happy": return "😊"
        case "normal": return "😐"
        case "down": return "😔"
        case "angry": return "😡"
        default: return "✨"
        }
    }"""
new_emoji_func = """    private func moodIcon(for type: String) -> String {
        switch type {
        case "excited": return "sun.max.fill"
        case "happy": return "cloud.sun.fill"
        case "normal": return "cloud.fill"
        case "down": return "cloud.drizzle.fill"
        case "angry": return "cloud.bolt.rain.fill"
        default: return "sparkles"
        }
    }
    
    private func moodColor(for type: String) -> Color {
        switch type {
        case "excited": return Color.orange
        case "happy": return Color.yellow
        case "normal": return Color.gray
        case "down": return Color.blue
        case "angry": return Color.purple
        default: return DS.primary
        }
    }"""
content = content.replace(old_emoji_func, new_emoji_func)

# We need to replace it in TimelineItem too
content = content.replace("""    private func emoji(for type: String) -> String {
        switch type {
        case "excited": return "🤩"
        case "happy": return "😊"
        case "normal": return "😐"
        case "down": return "😔"
        case "angry": return "😡"
        default: return "✨"
        }
    }""", new_emoji_func)

# Remove navigation view modifiers
nav_modifiers = """            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DS.onSurfaceVariant)
                            .font(.system(size: 24))
                    }
                }
            }
        }"""
content = content.replace(nav_modifiers, "        }\n")

with open('Sources/MoodRecorderView.swift', 'w') as f:
    f.write(content)
