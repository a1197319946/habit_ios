import re

with open('Sources/ContentView.swift', 'r') as f:
    code = f.read()

# 1. Wrap NavigationStack with AppLockView
target = "NavigationStack {"
insertion = """AppLockView {
        NavigationStack {"""
code = code.replace(target, insertion)

# 2. Add Paywall sheet and close AppLockView
target2 = "    }\n}"
insertion2 = """        }
        .sheet(isPresented: $appSettings.showPaywall) {
            PaywallView()
                .presentationDragIndicator(.visible)
        }
    }
}"""
code = re.sub(r'    \}\n\}$', insertion2, code)

with open('Sources/ContentView.swift', 'w') as f:
    f.write(code)
