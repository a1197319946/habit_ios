import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTier: Int = 1 // Default to Yearly
    @State private var isProcessing = false
    @State private var showRetention = false
    @State private var isDismissingFromCloseButton = false
    
    var body: some View {
        NavigationView {
            ZStack {
            DS.bgPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DS.spacingXL) {
                        // Title
                        VStack(spacing: DS.spacingS) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.yellow)
                                .shadow(color: .yellow.opacity(0.5), radius: 10, x: 0, y: 5)
                            
                            Text("Little Habit Premium".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 28, weight: .black))
                                .foregroundColor(DS.onSurface)
                            
                            Text("Unlock your full potential".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(DS.onSurfaceVariant)
                        }
                        .padding(.top, DS.spacingM)
                        
                        // Features List
                        VStack(alignment: .leading, spacing: DS.spacingM) {
                            FeatureRow(icon: "nosign", color: .yellow, title: "Ad-Free Experience".tr(appSettings.resolvedLanguage), subtitle: "Reduce the resistance to your daily habits.".tr(appSettings.resolvedLanguage))
                            FeatureRow(icon: "paintpalette.fill", color: .purple, title: "Theme Colors".tr(appSettings.resolvedLanguage), subtitle: "Personalize your app with custom colors".tr(appSettings.resolvedLanguage))
                            FeatureRow(icon: "moon.stars.fill", color: .blue, title: "Dark Mode".tr(appSettings.resolvedLanguage), subtitle: "Reduce eye strain with a sleek dark theme".tr(appSettings.resolvedLanguage))
                            FeatureRow(icon: "lock.shield.fill", color: .green, title: "App Lock".tr(appSettings.resolvedLanguage), subtitle: "Protect your habits with Face ID / Touch ID".tr(appSettings.resolvedLanguage))
                            FeatureRow(icon: "infinity", color: .orange, title: "Unlimited Habits".tr(appSettings.resolvedLanguage), subtitle: "Create as many habits as you want".tr(appSettings.resolvedLanguage))
                            FeatureRow(icon: "arrow.up.arrow.down.circle.fill", color: .pink, title: "Import / Export Data".tr(appSettings.resolvedLanguage), subtitle: "Backup to Excel & Import".tr(appSettings.resolvedLanguage))
                            FeatureRow(icon: "icloud.fill", color: .cyan, title: "iCloud Sync".tr(appSettings.resolvedLanguage), subtitle: "Keep your habits synced across all devices".tr(appSettings.resolvedLanguage))
                        }
                        .padding(.horizontal, DS.spacingL)
                        
                        // Pricing Tiers
                        VStack(spacing: DS.spacingM) {
                            PricingCard(
                                isSelected: selectedTier == 0,
                                title: "Monthly Card".tr(appSettings.resolvedLanguage),
                                price: "¥2.9",
                                originalPrice: "¥6",
                                subtitle: "Billed monthly".tr(appSettings.resolvedLanguage),
                                tag: nil
                            )
                            .onTapGesture { withAnimation { selectedTier = 0 } }
                            
                            PricingCard(
                                isSelected: selectedTier == 1,
                                title: "Yearly Card".tr(appSettings.resolvedLanguage),
                                price: "¥29.9",
                                originalPrice: "¥38",
                                subtitle: "Billed yearly".tr(appSettings.resolvedLanguage),
                                tag: "POPULAR".tr(appSettings.resolvedLanguage)
                            )
                            .onTapGesture { withAnimation { selectedTier = 1 } }
                            
                            PricingCard(
                                isSelected: selectedTier == 2,
                                title: "Lifetime Card".tr(appSettings.resolvedLanguage),
                                price: "¥39.9",
                                originalPrice: "¥78",
                                subtitle: "One-time payment".tr(appSettings.resolvedLanguage),
                                tag: "BEST VALUE".tr(appSettings.resolvedLanguage)
                            )
                            .onTapGesture { withAnimation { selectedTier = 2 } }
                        }
                        .padding(.horizontal, DS.spacingL)
                        
                        // Purchase Button
                        VStack(spacing: 8) {
                            let premiumGold = Color(hex: "D4AF37")
                            let btnColor = selectedTier == 1 ? premiumGold : DS.primary
                            
                            Button(action: { simulatePurchase() }) {
                                HStack {
                                    Spacer()
                                    if isProcessing {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text(selectedTier == 1 ? "Start Free Trial".tr(appSettings.resolvedLanguage) : "Purchase Now".tr(appSettings.resolvedLanguage))
                                            .font(.system(size: 18, weight: .bold))
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 16)
                                .background(btnColor)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: DS.cornerL, style: .continuous))
                                .shadow(color: btnColor.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .disabled(isProcessing)
                            
                            if selectedTier == 1 {
                                Text("15 天免费试用，结束后按 ¥29.9/年收费".tr(appSettings.resolvedLanguage))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(DS.onSurfaceVariant)
                                Text("试用期间可以随时取消，不扣费".tr(appSettings.resolvedLanguage))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(DS.onSurfaceVariant)
                            }
                        }
                        .padding(.horizontal, DS.spacingL)
                        .padding(.top, DS.spacingM)
                        
                        // Terms
                        VStack(spacing: 4) {
                            Text("By continuing, you agree to our".tr(appSettings.resolvedLanguage))
                            HStack(spacing: 4) {
                                Text("Terms of Service".tr(appSettings.resolvedLanguage)).underline()
                                Text("and".tr(appSettings.resolvedLanguage))
                                Text("Privacy Policy".tr(appSettings.resolvedLanguage)).underline()
                            }
                        }
                        .font(.system(size: 12))
                        .foregroundColor(DS.onSurfaceVariant.opacity(0.6))
                        .padding(.bottom, DS.spacingXL)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { simulatePurchase() }) {
                        Text("Restore Purchase".tr(appSettings.resolvedLanguage))
                            .foregroundColor(DS.primary)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if !appSettings.isPremium {
                            showRetention = true
                        } else {
                            dismiss()
                        }
                    }) {
                        Text("Close".tr(appSettings.resolvedLanguage))
                            .foregroundColor(DS.primary)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
        } // ZStack
        }
        .preferredColorScheme(appSettings.colorScheme)
        .interactiveDismissDisabled(!appSettings.isPremium)
        .onAttemptToDismiss {
            if !appSettings.isPremium {
                showRetention = true
            }
        }
        .overlay {
            if showRetention {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showRetention = false
                        }
                    
                    RetentionOfferSheet(
                        onDecline: {
                            isDismissingFromCloseButton = true
                            dismiss()
                        },
                        onAccept: {
                            isDismissingFromCloseButton = true
                            simulatePurchase()
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showRetention)
    }
    
    private func simulatePurchase() {
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isProcessing = false
            withAnimation {
                appSettings.isPremium = true
                dismiss()
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: DS.spacingM) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DS.onSurface)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(DS.onSurfaceVariant)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }
}

struct PricingCard: View {
    @EnvironmentObject private var appSettings: AppSettings
    let isSelected: Bool
    let title: String
    let price: String
    let originalPrice: String
    let subtitle: String
    let tag: String?
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isSelected ? DS.primary : DS.onSurface)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DS.onSurfaceVariant)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Limited Time Offer".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(4)
                            
                        Text(originalPrice)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(DS.onSurfaceVariant)
                            .strikethrough(true, color: DS.onSurfaceVariant)
                    }
                    
                    Text(price)
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(isSelected ? DS.primary : DS.onSurface)
                }
            }
            .padding(.horizontal, DS.spacingL)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: DS.cornerL, style: .continuous)
                    .fill(isSelected ? (isSelected && title.contains("Year") || title.contains("年度") ? Color(hex: "D4AF37").opacity(0.1) : DS.primary.opacity(0.1)) : DS.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.cornerL, style: .continuous)
                    .stroke(isSelected ? (isSelected && title.contains("Year") || title.contains("年度") ? Color(hex: "D4AF37") : DS.primary) : DS.outlineVariant, lineWidth: isSelected ? 2 : 1)
            )
            
            if let tag = tag {
                Text(tag)
                    .font(.system(size: 10, weight: .black))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .offset(x: 16, y: -10)
            }
        }
    }
}
