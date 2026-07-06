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
    
    private var updateListenerTask: Task<Void, Never>? = nil
    
    // Support user specified IDs (1005, 1006, 1003) as well as bundle prefix variations
    private let productIDs: Set<String> = [
        "1005", "1006", "1003",
        "com.xiaodao.LittleHabitTracker.monthly",
        "com.xiaodao.LittleHabitTracker.yearly",
        "com.xiaodao.LittleHabitTracker.lifetime"
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
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        
        self.purchasedProductIDs = purchased
        
        // Sync with AppSettings in App Group UserDefaults
        let isPremium = !purchased.isEmpty
        if let defaults = UserDefaults(suiteName: "group.com.littlehabit.tracker") {
            defaults.set(isPremium, forKey: "isPremium")
        }
        UserDefaults.standard.set(isPremium, forKey: "isPremium")
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
