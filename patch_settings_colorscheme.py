import re

with open('Sources/SettingsView.swift', 'r') as f:
    code = f.read()

target = """        .sheet(isPresented: $appSettings.showPaywallFromSettings) {
            PaywallView()
                .presentationDragIndicator(.visible)
        }
    }
}"""

insertion = """        .sheet(isPresented: $appSettings.showPaywallFromSettings) {
            PaywallView()
                .presentationDragIndicator(.visible)
        }
        .preferredColorScheme(appSettings.colorScheme)
    }
}"""

code = code.replace(target, insertion)

with open('Sources/SettingsView.swift', 'w') as f:
    f.write(code)
