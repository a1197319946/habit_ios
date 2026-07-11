import re

with open('Sources/PaywallView.swift', 'r') as f:
    code = f.read()

target = """            }
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

insertion = """            }
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
        } // ZStack
        } // NavigationView
        .preferredColorScheme(appSettings.colorScheme)
    }"""

code = code.replace(target, insertion)

with open('Sources/PaywallView.swift', 'w') as f:
    f.write(code)
