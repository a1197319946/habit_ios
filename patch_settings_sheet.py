import re

with open('Sources/SettingsView.swift', 'r') as f:
    code = f.read()

# Replace all appSettings.showPaywall = true with appSettings.showPaywallFromSettings = true
code = code.replace("appSettings.showPaywall = true", "appSettings.showPaywallFromSettings = true")

# Find the end of SettingsView body to inject the sheet
target = """        }
    }
}

struct JSONDocument:"""

insertion = """        }
        .sheet(isPresented: $appSettings.showPaywallFromSettings) {
            PaywallView()
                .presentationDragIndicator(.visible)
        }
    }
}

struct JSONDocument:"""

code = code.replace(target, insertion)

with open('Sources/SettingsView.swift', 'w') as f:
    f.write(code)
