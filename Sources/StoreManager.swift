import Foundation
import StoreKit
import SwiftUI

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var membershipExpirationDate: Date? = nil
    @Published var isLifetimeMember: Bool = false
    
    private var updateListenerTask: Task<Void, Never>? = nil
    
    // Support user specified IDs (1005, 1006, 1003) as well as bundle prefix and common variations
    private let productIDs: Set<String> = [
        "1005", "1006", "1003",
        "monthly", "yearly", "lifetime",
        "month", "year", "vip", "pro",
        "com.xiaodao.LittleHabitTracker.monthly",
        "com.xiaodao.LittleHabitTracker.yearly",
        "com.xiaodao.LittleHabitTracker.lifetime",
        "com.xiaodao.LittleHabitTracker.month",
        "com.xiaodao.LittleHabitTracker.year",
        "com.xiaodao.LittleHabitTracker.vip",
        "com.xiaodao.LittleHabitTracker.pro",
        "com.littlehabit.tracker.monthly",
        "com.littlehabit.tracker.yearly",
        "com.littlehabit.tracker.lifetime",
        "tickday.monthly", "tickday.yearly", "tickday.lifetime",
        "tickday_monthly", "tickday_yearly", "tickday_lifetime",
        "TickDay_monthly", "TickDay_yearly", "TickDay_lifetime"
    ]
    
    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedRights()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func loadProducts() async {
        isLoading = true
        do {
            let loadedProducts = try await Product.products(for: productIDs)
            self.products = loadedProducts.sorted(by: { $0.price < $1.price })
            self.isLoading = false
            if loadedProducts.isEmpty {
                print("⚠️ [StoreKit] No products returned from App Store Connect. Please check: 1) In-App Purchase status is at least 'Ready to Submit' (not Missing Metadata); 2) Paid Applications Agreement is Active in App Store Connect; 3) Product IDs match exactly.")
            } else {
                print("✅ [StoreKit] Successfully loaded \(loadedProducts.count) products from App Store Connect: \(loadedProducts.map { "\($0.id): \($0.displayName) (\($0.displayPrice))" })")
            }
        } catch {
            print("Failed to fetch products: \(error)")
            self.errorMessage = "获取产品列表失败：\(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePurchasedRights()
            return true
            
        case .userCancelled, .pending:
            return false
            
        @unknown default:
            return false
        }
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedRights()
        } catch {
            print("Restore failed: \(error)")
        }
    }
    
    func updatePurchasedRights() async {
        var purchased: Set<String> = []
        var latestExpiration: Date? = nil
        var lifetime = false
        
        for await result in Transaction.currentEntitlements {
            print("🔍 [StoreKit] Found an entitlement in local cache!")
            do {
                let transaction = try checkVerified(result)
                print("🔍 [StoreKit] Transaction ID: \(transaction.id), Product ID: \(transaction.productID)")
                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                    
                    if let expDate = transaction.expirationDate {
                        if latestExpiration == nil || expDate > latestExpiration! {
                            latestExpiration = expDate
                        }
                    } else {
                        lifetime = true
                    }
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        print("🔍 [StoreKit] Purchased products count: \(purchased.count)")
        
        self.purchasedProductIDs = purchased
        self.membershipExpirationDate = latestExpiration
        self.isLifetimeMember = lifetime
        
        // Sync with AppSettings in App Group UserDefaults
        let isPremium = !purchased.isEmpty
        if let defaults = UserDefaults(suiteName: "group.com.littlehabit.tracker") {
            defaults.set(isPremium, forKey: "isPremium")
            defaults.set(lifetime, forKey: "isLifetimeMember")
            if let expDate = latestExpiration {
                defaults.set(expDate.timeIntervalSince1970, forKey: "membershipExpirationDate")
            } else {
                defaults.removeObject(forKey: "membershipExpirationDate")
            }
        }
        UserDefaults.standard.set(isPremium, forKey: "isPremium")
        UserDefaults.standard.set(lifetime, forKey: "isLifetimeMember")
        if let expDate = latestExpiration {
            UserDefaults.standard.set(expDate.timeIntervalSince1970, forKey: "membershipExpirationDate")
        } else {
            UserDefaults.standard.removeObject(forKey: "membershipExpirationDate")
        }
    }
    
    func expirationDateFormatted(in language: AppLanguage) -> String {
        let lifetime = isLifetimeMember || UserDefaults.standard.bool(forKey: "isLifetimeMember")
        if lifetime {
            return L10n.validUntilLifetimeAccess.tr(language)
        }
        
        var targetDate = membershipExpirationDate
        if targetDate == nil {
            let ts = UserDefaults.standard.double(forKey: "membershipExpirationDate")
            if ts > 0 {
                targetDate = Date(timeIntervalSince1970: ts)
            }
        }
        
        if let date = targetDate {
            let formatter = DateFormatter()
            if language == .chinese {
                formatter.dateFormat = "yyyy年MM月dd日"
            } else {
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                formatter.locale = Locale(identifier: "en_US")
            }
            let dateStr = formatter.string(from: date)
            return L10n.validUntil.tr(language) + dateStr
        }
        
        return L10n.statusActivePremium.tr(language)
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    private func listenForTransactions() -> Task<Void, Never> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerifiedAsync(result)
                    await transaction.finish()
                    await self.updatePurchasedRights()
                } catch {
                    print("Transaction listener error: \(error)")
                }
            }
        }
    }
    
    private func checkVerifiedAsync<T>(_ result: VerificationResult<T>) async throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    func getProduct(for id: String) -> Product? {
        return products.first(where: { $0.id == id })
    }
}

enum StoreError: Error {
    case failedVerification
}
