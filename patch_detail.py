import re

with open('Sources/HabitDetailView.swift', 'r') as f:
    content = f.read()

# Replace "Frequency" and "Total Amount" string with localized "次数目标" and "总量目标"
content = content.replace('"Frequency".tr(appSettings.resolvedLanguage)', '"次数目标".tr(appSettings.resolvedLanguage)')
content = content.replace('"Total Amount".tr(appSettings.resolvedLanguage)', '"总量目标".tr(appSettings.resolvedLanguage)')

# Add .tr to units picker
old_picker = """                                        Picker("", selection: $amountUnit) {
                                            ForEach(unitOptions, id: \.self) { Text($0).tag($0) }
                                        }"""
new_picker = """                                        Picker("", selection: $amountUnit) {
                                            ForEach(unitOptions, id: \.self) { Text($0.tr(appSettings.resolvedLanguage)).tag($0) }
                                        }"""
content = content.replace(old_picker, new_picker)

# Replace the submit button with the white background gradient
old_button = """            // Sticky Bottom Button
            VStack {
                Spacer()
                Button(action: submit) {
                    Text(isSubmitting ? "Creating...".tr(appSettings.resolvedLanguage) : (habit == nil ? "Create Habit".tr(appSettings.resolvedLanguage) : "Save Changes".tr(appSettings.resolvedLanguage)))
                        .labelMd()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#9D8DFF"), Color(hex: "#B5A8FF")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(100)
                        .shadow(color: Color(hex: "#9D8DFF").opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(name.isEmpty || isSubmitting)
                .opacity(name.isEmpty ? 0.5 : 1)
                .padding(.horizontal, DS.spacingL)
                .padding(.bottom, DS.spacingL)
                .padding(.top, 16)
            }"""

new_button = """            // Sticky Bottom Button
            VStack {
                Spacer()
                VStack(spacing: 0) {
                    Button(action: submit) {
                        Text(isSubmitting ? "Creating...".tr(appSettings.resolvedLanguage) : (habit == nil ? "Create Habit".tr(appSettings.resolvedLanguage) : "Save Changes".tr(appSettings.resolvedLanguage)))
                            .labelMd()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(DS.primary)
                            .cornerRadius(100)
                            .shadow(color: DS.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(name.isEmpty || isSubmitting)
                    .opacity(name.isEmpty ? 0.5 : 1)
                    .padding(.horizontal, DS.spacingL)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
                .background(
                    LinearGradient(colors: [DS.bgPrimary.opacity(0), DS.bgPrimary, DS.bgPrimary], startPoint: .top, endPoint: .bottom)
                )
                .ignoresSafeArea(edges: .bottom)
            }"""

content = content.replace(old_button, new_button)

with open('Sources/HabitDetailView.swift', 'w') as f:
    f.write(content)
