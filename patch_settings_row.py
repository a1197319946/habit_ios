import re
with open('Sources/SettingsView.swift', 'r') as f:
    code = f.read()

# 1. Fix SettingsRow: replace Button with HStack and onTapGesture
target_row = """    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.spacingM) {"""
insertion_row = """    var body: some View {
        HStack(spacing: DS.spacingM) {"""
code = code.replace(target_row, insertion_row)

target_end_row = """            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}"""
insertion_end_row = """            .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}"""
code = code.replace(target_end_row, insertion_end_row)

# 2. Add Premium Banner at the top
target_top = """            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.spacingXL) {"""
insertion_top = """            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.spacingL) {
                    
                    // Premium Banner
                    if !appSettings.isPremium {
                        Button(action: {
                            appSettings.showPaywall = true
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
                        .padding(.horizontal, DS.spacingL)
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
                        .padding(.horizontal, DS.spacingL)
                        .padding(.top, DS.spacingS)
                    }"""
code = code.replace(target_top, insertion_top)

with open('Sources/SettingsView.swift', 'w') as f:
    f.write(code)
