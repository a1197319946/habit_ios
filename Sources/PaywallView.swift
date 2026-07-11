import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTier: Int = 1 // Default to Yearly
    @State private var isProcessing = false
    @State private var showRetention = false
    @State private var isDismissingFromCloseButton = false
    @State private var showStoreErrorAlert = false
    @State private var storeErrorMessage = ""
    @ObservedObject private var storeManager = StoreManager.shared
    
    private var monthlyProduct: Product? {
        storeManager.products.first(where: {
            $0.id == "1005" || $0.id.contains("month") || ($0.subscription?.subscriptionPeriod.unit == .month && $0.subscription?.subscriptionPeriod.value == 1)
        })
    }
    private var yearlyProduct: Product? {
        storeManager.products.first(where: {
            $0.id == "1006" || $0.id.contains("year") || ($0.subscription?.subscriptionPeriod.unit == .year && $0.subscription?.subscriptionPeriod.value == 1)
        })
    }
    private var lifetimeProduct: Product? {
        storeManager.products.first(where: {
            $0.id == "1003" || $0.id.contains("lifetime") || $0.id.contains("vip") || $0.id.contains("pro") || $0.type == .nonConsumable
        })
    }
    
    private func productTitle(for product: Product?, defaultTitle: String) -> String {
        if let name = product?.displayName, !name.isEmpty {
            return name
        }
        return defaultTitle.tr(appSettings.resolvedLanguage)
    }
    
    private func productSubtitle(for product: Product?, defaultSubtitle: String) -> String {
        if let desc = product?.description, !desc.isEmpty {
            return desc
        }
        return defaultSubtitle.tr(appSettings.resolvedLanguage)
    }
    
    @ViewBuilder private var tiersSection: some View {
        VStack(spacing: DS.spacingM) {
            PricingCard(
                isSelected: selectedTier == 0,
                title: productTitle(for: monthlyProduct, defaultTitle: "Monthly Card"),
                price: monthlyProduct?.displayPrice ?? "¥2.9",
                originalPrice: "¥6",
                subtitle: productSubtitle(for: monthlyProduct, defaultSubtitle: "按月扣费"),
                tag: nil
            )
            .onTapGesture { withAnimation { selectedTier = 0 } }
            
            PricingCard(
                isSelected: selectedTier == 1,
                title: productTitle(for: yearlyProduct, defaultTitle: "Yearly Card"),
                price: yearlyProduct?.displayPrice ?? "¥29.9",
                originalPrice: "¥38",
                subtitle: productSubtitle(for: yearlyProduct, defaultSubtitle: "按年扣费"),
                tag: "POPULAR".tr(appSettings.resolvedLanguage)
            )
            .onTapGesture { withAnimation { selectedTier = 1 } }
            
            PricingCard(
                isSelected: selectedTier == 2,
                title: productTitle(for: lifetimeProduct, defaultTitle: "Lifetime Card"),
                price: lifetimeProduct?.displayPrice ?? "¥39.9",
                originalPrice: "¥78",
                subtitle: productSubtitle(for: lifetimeProduct, defaultSubtitle: "一次性付费"),
                tag: "BEST VALUE".tr(appSettings.resolvedLanguage)
            )
            .onTapGesture { withAnimation { selectedTier = 2 } }
        }
        .padding(.horizontal, DS.spacingL)
    }
    
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
                        
                        if appSettings.isPremium {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(Color(hex: "D4AF37"))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("您已是尊享会员".tr(appSettings.resolvedLanguage))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(DS.onSurface)
                                    Text(StoreManager.shared.expirationDateFormatted(in: appSettings.resolvedLanguage))
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(DS.onSurfaceVariant)
                                }
                                Spacer()
                            }
                            .padding(DS.spacingM)
                            .background(Color(hex: "D4AF37").opacity(0.15))
                            .cornerRadius(DS.cornerM)
                            .overlay(
                                RoundedRectangle(cornerRadius: DS.cornerM)
                                    .stroke(Color(hex: "D4AF37"), lineWidth: 1)
                            )
                            .padding(.horizontal, DS.spacingL)
                        }
                        
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
                        
                        if storeManager.products.isEmpty && !storeManager.isLoading {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 14))
                                Text(storeManager.errorMessage ?? "无法从苹果后台获取订阅价格，当前显示默认参考价。请检查：1) 苹果后台内购项目状态不为“缺少元数据”；2) App Store Connect 付费协议已生效；3) 产品 ID 匹配。".tr(appSettings.resolvedLanguage))
                                    .font(.system(size: 12))
                                    .foregroundColor(DS.onSurfaceVariant)
                            }
                            .padding(DS.spacingM)
                            .background(Color.orange.opacity(0.12))
                            .cornerRadius(DS.cornerS)
                            .padding(.horizontal, DS.spacingL)
                        }
                        
                        // Pricing Tiers
                        tiersSection
                        
                        // Purchase Button
                        VStack(spacing: 8) {
                            let premiumGold = Color(hex: "D4AF37")
                            let btnColor = selectedTier == 1 ? premiumGold : DS.primary
                            
                            Button(action: { executePurchase() }) {
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
                            
                            if selectedTier == 0 {
                                let monthPrice = monthlyProduct?.displayPrice ?? "¥2.9"
                                Text(appSettings.resolvedLanguage == .chinese ? "自动续期，\(monthPrice)/月，可随时取消" : "Auto-renewable, \(monthPrice)/month, cancel anytime")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(DS.onSurfaceVariant)
                            } else if selectedTier == 1 {
                                let yearPrice = yearlyProduct?.displayPrice ?? "¥29.9"
                                Text(appSettings.resolvedLanguage == .chinese ? "15 天免费试用，结束后按 \(yearPrice)/年收费" : "15-day free trial, then \(yearPrice)/year")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(DS.onSurfaceVariant)
                                Text("试用期间可以随时取消，不扣费".tr(appSettings.resolvedLanguage))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(DS.onSurfaceVariant)
                            } else if selectedTier == 2 {
                                Text(appSettings.resolvedLanguage == .chinese ? "一次性付费，永久解锁全部尊享权益" : "One-time payment, lifetime access to all features")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(DS.onSurfaceVariant)
                            }
                        }
                        .padding(.horizontal, DS.spacingL)
                        .padding(.top, DS.spacingM)
                        
                        // Redeem Offer Code Button
                        Button {
                            if #available(iOS 16.0, *) {
                                Task {
                                    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                                        try? await AppStore.presentOfferCodeRedeemSheet(in: scene)
                                    }
                                }
                            } else {
                                SKPaymentQueue.default().presentCodeRedemptionSheet()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "gift.fill")
                                Text("Redeem Offer Code".tr(appSettings.resolvedLanguage))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(DS.primary)
                        }
                        .padding(.top, DS.spacingS)
                        
                        // Terms & Privacy Links (Required by Apple App Store Review Guideline 3.1.2)
                        VStack(spacing: 6) {
                            Text("By continuing, you agree to our".tr(appSettings.resolvedLanguage))
                            HStack(spacing: 8) {
                                Button {
                                    if let url = URL(string: "https://a1197319946.github.io/habit_ios/support.html") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    Text("Terms of Service".tr(appSettings.resolvedLanguage))
                                        .underline()
                                }
                                
                                Text("and".tr(appSettings.resolvedLanguage))
                                
                                Button {
                                    if let url = URL(string: "https://a1197319946.github.io/habit_ios/privacy.html") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    Text("Privacy Policy".tr(appSettings.resolvedLanguage))
                                        .underline()
                                }
                            }
                            .foregroundColor(DS.primary)
                        }
                        .font(.system(size: 12))
                        .foregroundColor(DS.onSurfaceVariant.opacity(0.8))
                        .padding(.bottom, DS.spacingXL)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { executeRestore() }) {
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
                            executePurchase()
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showRetention)
        .onAppear {
            if storeManager.products.isEmpty {
                Task {
                    await storeManager.loadProducts()
                }
            }
        }
        .alert("提示".tr(appSettings.resolvedLanguage), isPresented: $showStoreErrorAlert) {
            Button("确定".tr(appSettings.resolvedLanguage), role: .cancel) { }
        } message: {
            Text(storeErrorMessage)
        }
    }
    
    private func executePurchase() {
        isProcessing = true
        let targetID: String
        switch selectedTier {
        case 0: targetID = "1005"
        case 2: targetID = "1003"
        default: targetID = "1006"
        }
        
        let product = storeManager.products.first(where: {
            $0.id == targetID ||
            (selectedTier == 0 && ($0.id.contains("month") || ($0.subscription?.subscriptionPeriod.unit == .month && $0.subscription?.subscriptionPeriod.value == 1))) ||
            (selectedTier == 1 && ($0.id.contains("year") || ($0.subscription?.subscriptionPeriod.unit == .year && $0.subscription?.subscriptionPeriod.value == 1))) ||
            (selectedTier == 2 && ($0.id.contains("lifetime") || $0.id.contains("vip") || $0.id.contains("pro") || $0.type == .nonConsumable))
        })
        
        if let product = product {
            Task {
                do {
                    let success = try await storeManager.purchase(product)
                    DispatchQueue.main.async {
                        isProcessing = false
                        if success {
                            withAnimation {
                                appSettings.isPremium = true
                                dismiss()
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        isProcessing = false
                        storeErrorMessage = "购买失败：\(error.localizedDescription)"
                        showStoreErrorAlert = true
                        print("Purchase error: \(error)")
                    }
                }
            }
        } else {
            #if DEBUG
            // In Xcode Debug mode without a StoreKit config attached, allow simulation
            simulatePurchase()
            #else
            isProcessing = false
            storeErrorMessage = "无法从 App Store 获取产品价格与配置，请检查网络连接或确认苹果后台产品已生效。".tr(appSettings.resolvedLanguage)
            showStoreErrorAlert = true
            #endif
        }
    }
    
    private func executeRestore() {
        isProcessing = true
        Task {
            await storeManager.restorePurchases()
            DispatchQueue.main.async {
                isProcessing = false
                if !storeManager.purchasedProductIDs.isEmpty || appSettings.isPremium {
                    withAnimation {
                        appSettings.isPremium = true
                        dismiss()
                    }
                } else {
                    storeErrorMessage = "没有可恢复的购买项".tr(appSettings.resolvedLanguage)
                    showStoreErrorAlert = true
                }
            }
        }
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
