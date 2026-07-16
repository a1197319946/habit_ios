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
        return defaultTitle.tr(appSettings.resolvedLanguage)
    }
    
    private func productSubtitle(for product: Product?, defaultSubtitle: String) -> String {
        return defaultSubtitle.tr(appSettings.resolvedLanguage)
    }
    
    private func formattedSubscriptionPeriod(for product: Product?) -> String {
        guard let product = product,
              let period = product.subscription?.subscriptionPeriod else {
            return ""
        }
        let value = period.value
        
        if appSettings.resolvedLanguage == .chinese {
            let unit: String
            switch period.unit {
            case .day: unit = "天"
            case .week: unit = "周"
            case .month: unit = value == 1 ? "月" : "个月"
            case .year: unit = "年"
            @unknown default: unit = ""
            }
            if value == 1 {
                return "/\(unit)"
            } else {
                return "/\(value)\(unit)"
            }
        } else {
            let unit: String
            switch period.unit {
            case .day: unit = "day"
            case .week: unit = "week"
            case .month: unit = "month"
            case .year: unit = "year"
            @unknown default: unit = ""
            }
            if value == 1 {
                return "/\(unit)"
            } else {
                return "/\(value) \(unit)s"
            }
        }
    }
    
    @ViewBuilder private var tiersSection: some View {
        VStack(spacing: DS.spacingM) {
            PricingCard(
                isSelected: selectedTier == 0,
                title: productTitle(for: monthlyProduct, defaultTitle: "Monthly Card"),
                price: monthlyProduct?.displayPrice ?? "",
                originalPrice: "",
                subtitle: productSubtitle(for: monthlyProduct, defaultSubtitle: "按月扣费"),
                tag: nil
            )
            .onTapGesture { withAnimation { selectedTier = 0 } }
            
            PricingCard(
                isSelected: selectedTier == 1,
                title: productTitle(for: yearlyProduct, defaultTitle: "Yearly Card"),
                price: yearlyProduct?.displayPrice ?? "",
                originalPrice: "",
                subtitle: productSubtitle(for: yearlyProduct, defaultSubtitle: "按年扣费"),
                tag: L10n.popular.tr(appSettings.resolvedLanguage)
            )
            .onTapGesture { withAnimation { selectedTier = 1 } }
            
            PricingCard(
                isSelected: selectedTier == 2,
                title: productTitle(for: lifetimeProduct, defaultTitle: "Lifetime Card"),
                price: lifetimeProduct?.displayPrice ?? "",
                originalPrice: "",
                subtitle: productSubtitle(for: lifetimeProduct, defaultSubtitle: "一次性付费"),
                tag: L10n.bestValue.tr(appSettings.resolvedLanguage)
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
                            
                            Text(L10n.tickdayPremium.tr(appSettings.resolvedLanguage))
                                .font(.system(size: 28, weight: .black))
                                .foregroundColor(DS.onSurface)
                            
                            Text(L10n.unlockYourFullPotential.tr(appSettings.resolvedLanguage))
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
                                    Text(L10n.youAreAPremiumMember.tr(appSettings.resolvedLanguage))
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
                            FeatureRow(icon: "nosign", color: .yellow, title: L10n.adFreeExperience.tr(appSettings.resolvedLanguage), subtitle: L10n.reduceTheResistanceToYourDailyHabits.tr(appSettings.resolvedLanguage))
                            FeatureRow(icon: "paintpalette.fill", color: .purple, title: L10n.themeColors.tr(appSettings.resolvedLanguage), subtitle: L10n.personalizeYourAppWithCustomColors.tr(appSettings.resolvedLanguage))
                            FeatureRow(icon: "moon.stars.fill", color: .blue, title: L10n.darkMode.tr(appSettings.resolvedLanguage), subtitle: L10n.reduceEyeStrainWithASleekDarkTheme.tr(appSettings.resolvedLanguage))
                            FeatureRow(icon: "infinity", color: .orange, title: L10n.unlimitedHabits.tr(appSettings.resolvedLanguage), subtitle: L10n.createAsManyHabitsAsYouWantFreeVersionMax5.tr(appSettings.resolvedLanguage))
                            FeatureRow(icon: "icloud.fill", color: .cyan, title: L10n.icloudSync.tr(appSettings.resolvedLanguage), subtitle: L10n.keepYourHabitsSyncedAcrossAllDevices.tr(appSettings.resolvedLanguage))
                        }
                        .padding(.horizontal, DS.spacingL)
                        
                        if storeManager.products.isEmpty && !storeManager.isLoading {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 14))
                                Text(storeManager.errorMessage ?? L10n.unableToFetchSubscriptionPricingFromAppStoreConnectShowingDefaultReferencePricesPleaseCheck1InAppPurchaseStatusIsNotMissingMetadata2PaidApplicationsAgreementIsActive3ProductIdsMatchExactly.tr(appSettings.resolvedLanguage))
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
                                        Text(selectedTier == 1 ? L10n.startFreeTrial.tr(appSettings.resolvedLanguage) : L10n.purchaseNow.tr(appSettings.resolvedLanguage))
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
                                let monthPrice = monthlyProduct?.displayPrice ?? ""
                                let periodStr = formattedSubscriptionPeriod(for: monthlyProduct)
                                let priceText = "\(monthPrice)\(periodStr)"
                                Text(L10n.autoRenewablePriceCancelAnytime.tr(appSettings.resolvedLanguage).replacingOccurrences(of: "{price}", with: priceText))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(DS.onSurfaceVariant)
                            } else if selectedTier == 1 {
                                let yearPrice = yearlyProduct?.displayPrice ?? ""
                                let periodStr = formattedSubscriptionPeriod(for: yearlyProduct)
                                let priceText = "\(yearPrice)\(periodStr)"
                                Text(L10n.firstMonthFreeThenPrice.tr(appSettings.resolvedLanguage).replacingOccurrences(of: "{price}", with: priceText))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(DS.onSurfaceVariant)
                                Text(L10n.cancelAnytimeDuringTrialNoCharge.tr(appSettings.resolvedLanguage))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(DS.onSurfaceVariant)
                            } else if selectedTier == 2 {
                                Text(L10n.oneTimePaymentLifetimeAccessToAllFeatures.tr(appSettings.resolvedLanguage))
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
                                Text(L10n.redeemOfferCode1.tr(appSettings.resolvedLanguage))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(DS.primary)
                        }
                        .padding(.top, DS.spacingS)
                        
                        // Terms & Privacy Links & Disclaimers (Required by Apple App Store Review Guideline 3.1.2)
                        VStack(spacing: 8) {
                            Text(L10n.paymentWillBeChargedToYourItunesAccountAtConfirmationOfPurchaseSubscriptionAutomaticallyRenewsUnlessAutoRenewIsTurnedOffAtLeast24HoursBeforeTheEndOfTheCurrentPeriodAccountWillBeChargedForRenewalWithin24HoursPriorToTheEndOfTheCurrentPeriodYouCanManageAndCancelYourSubscriptionsInYourAppStoreAccountSettings.tr(appSettings.resolvedLanguage))
                                .multilineTextAlignment(.center)
                                .font(.system(size: 11))
                                .foregroundColor(DS.onSurfaceVariant.opacity(0.7))
                                .padding(.horizontal, DS.spacingS)
                                .padding(.bottom, 4)
                            
                            Text(L10n.byContinuingYouAgreeToOur.tr(appSettings.resolvedLanguage))
                                .font(.system(size: 12))
                            HStack(spacing: 8) {
                                Button {
                                    if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    Text(L10n.termsOfService.tr(appSettings.resolvedLanguage))
                                        .underline()
                                }
                                
                                Text(L10n.and.tr(appSettings.resolvedLanguage))
                                
                                Button {
                                    if let url = URL(string: "https://a1197319946.github.io/habit_ios/privacy.html") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    Text(L10n.privacyPolicy.tr(appSettings.resolvedLanguage))
                                        .underline()
                                }
                            }
                            .foregroundColor(DS.primary)
                            .font(.system(size: 12))
                        }
                        .foregroundColor(DS.onSurfaceVariant.opacity(0.8))
                        .padding(.bottom, DS.spacingXL)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { executeRestore() }) {
                        Text(L10n.restore.tr(appSettings.resolvedLanguage))
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
                        Text(L10n.close.tr(appSettings.resolvedLanguage))
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
        .alert(L10n.notice.tr(appSettings.resolvedLanguage), isPresented: $showStoreErrorAlert) {
            Button(L10n.ok1.tr(appSettings.resolvedLanguage), role: .cancel) { }
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
                        storeErrorMessage = "\(L10n.purchaseFailed.tr(appSettings.resolvedLanguage))：\(error.localizedDescription)"
                        showStoreErrorAlert = true
                        print("Purchase error: \(error)")
                    }
                }
            }
        } else {
            isProcessing = false
            storeErrorMessage = "无法从 App Store 获取产品价格与配置，无法发起购买。请检查：1.网络连接 2.苹果后台产品状态(不能是需要开发者操作) 3.确保已签署《付费应用程序协议》。".tr(appSettings.resolvedLanguage)
            showStoreErrorAlert = true
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
                    storeErrorMessage = L10n.noPurchasesToRestore.tr(appSettings.resolvedLanguage)
                    showStoreErrorAlert = true
                }
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
                    if !originalPrice.isEmpty {
                        HStack(spacing: 6) {
                            Text(L10n.limitedTimeOffer.tr(appSettings.resolvedLanguage))
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
