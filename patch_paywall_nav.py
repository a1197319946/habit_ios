import re

with open('Sources/PaywallView.swift', 'r') as f:
    code = f.read()

# Wrap in NavigationView
target1 = """    var body: some View {
        ZStack {"""

insertion1 = """    var body: some View {
        NavigationView {
            ZStack {"""
code = code.replace(target1, insertion1)

# Remove HStack header
target2 = """                // Header
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Text("Close".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DS.primary)
                    }
                }
                .padding()
                
                ScrollView(showsIndicators: false) {"""

insertion2 = """                ScrollView(showsIndicators: false) {"""
code = code.replace(target2, insertion2)

# Add toolbar to the end of ZStack
target3 = """            }
        }
        .preferredColorScheme(appSettings.colorScheme)
    }"""

insertion3 = """            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Close".tr(appSettings.resolvedLanguage))
                            .foregroundColor(DS.primary)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
        }
        .preferredColorScheme(appSettings.colorScheme)
    }"""
code = code.replace(target3, insertion3)

with open('Sources/PaywallView.swift', 'w') as f:
    f.write(code)
