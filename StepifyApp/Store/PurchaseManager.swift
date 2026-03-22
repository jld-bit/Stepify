import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var unlockedUnlimitedGoals = false
    @Published private(set) var isLoading = false

    private let productIDs = [
        "com.stepify.unlimitedgoals",
        "com.stepify.advancedtracking"
    ]

    func prepare() async {
        await requestProducts()
        await refreshPurchasedState()
    }

    func requestProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: productIDs).sorted { $0.price < $1.price }
        } catch {
            print("Failed to load IAP products: \(error.localizedDescription)")
        }
    }

    func refreshPurchasedState() async {
        var unlocked = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == "com.stepify.unlimitedgoals" || transaction.productID == "com.stepify.advancedtracking" {
                unlocked = true
            }
        }

        unlockedUnlimitedGoals = unlocked
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result,
               case .verified(let transaction) = verification {
                unlockedUnlimitedGoals = true
                await transaction.finish()
            }
        } catch {
            print("Purchase failed: \(error.localizedDescription)")
        }
    }
}
