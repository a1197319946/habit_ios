import re

with open('Sources/PaywallView.swift', 'r') as f:
    code = f.read()

target = """        }
    }
    
    private func simulatePurchase() {"""

insertion = """        }
        .preferredColorScheme(appSettings.colorScheme)
    }
    
    private func simulatePurchase() {"""

code = code.replace(target, insertion)

with open('Sources/PaywallView.swift', 'w') as f:
    f.write(code)
