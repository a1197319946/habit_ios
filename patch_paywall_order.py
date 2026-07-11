import re
with open('Sources/PaywallView.swift', 'r') as f:
    code = f.read()

target = """                            PricingCard(
                                isSelected: selectedTier == 2,
                                title: "Lifetime".tr(appSettings.resolvedLanguage),
                                price: "¥36",
                                originalPrice: "¥138",
                                subtitle: "One-time payment".tr(appSettings.resolvedLanguage),
                                tag: "BEST VALUE".tr(appSettings.resolvedLanguage)
                            )
                            .onTapGesture { withAnimation { selectedTier = 2 } }
                            
                            PricingCard(
                                isSelected: selectedTier == 1,
                                title: "Yearly".tr(appSettings.resolvedLanguage),
                                price: "¥6",
                                originalPrice: "¥30",
                                subtitle: "Billed yearly".tr(appSettings.resolvedLanguage),
                                tag: "POPULAR".tr(appSettings.resolvedLanguage)
                            )
                            .onTapGesture { withAnimation { selectedTier = 1 } }"""

replacement = """                            PricingCard(
                                isSelected: selectedTier == 1,
                                title: "Yearly".tr(appSettings.resolvedLanguage),
                                price: "¥6",
                                originalPrice: "¥30",
                                subtitle: "Billed yearly".tr(appSettings.resolvedLanguage),
                                tag: "POPULAR".tr(appSettings.resolvedLanguage)
                            )
                            .onTapGesture { withAnimation { selectedTier = 1 } }
                            
                            PricingCard(
                                isSelected: selectedTier == 2,
                                title: "Lifetime".tr(appSettings.resolvedLanguage),
                                price: "¥36",
                                originalPrice: "¥138",
                                subtitle: "One-time payment".tr(appSettings.resolvedLanguage),
                                tag: "BEST VALUE".tr(appSettings.resolvedLanguage)
                            )
                            .onTapGesture { withAnimation { selectedTier = 2 } }"""

code = code.replace(target, replacement)
with open('Sources/PaywallView.swift', 'w') as f:
    f.write(code)
