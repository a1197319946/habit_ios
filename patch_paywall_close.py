import re

with open('Sources/PaywallView.swift', 'r') as f:
    code = f.read()

target = """                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(DS.tertiary.opacity(0.5))"""

insertion = """                        Text("Close".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DS.primary)"""

code = code.replace(target, insertion)

with open('Sources/PaywallView.swift', 'w') as f:
    f.write(code)
