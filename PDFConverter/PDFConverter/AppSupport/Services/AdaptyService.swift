import Foundation
import Adapty

enum SubscriptionType: String {
    case monthly
    case yearly
    case weeklyTrial
    case weekly
}

struct ProductModel {
    var monthly: AdaptyPaywallProduct?
    var yearly: AdaptyPaywallProduct?
    var weeklyTrial: AdaptyPaywallProduct?
    var weekly: AdaptyPaywallProduct?
}

final class AdaptyService: ObservableObject {
    static let shared = AdaptyService()
    
    @Published
    private(set) var subscriptionStatus: Bool = false
    
    @Published
    private(set) var products: [ProductModel] = []
    
    private let premiumAccessLevel = AppInfo.SDKAdapty.accessLevel
    private let productId = AppInfo.SDKAdapty.productId
    
    // MARK: - Проверка активной подписки перед стартом приложения
    func checkSubscriptionStatus() {
        Task {
            do {
                let profile = try await Adapty.getProfile()
                let isActive = profile.accessLevels[premiumAccessLevel]?.isActive ?? false
                DispatchQueue.main.async {
                    self.subscriptionStatus = isActive
                }
            } catch {
                print("Ошибка получения статуса подписки: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.subscriptionStatus = false
                }
            }
        }
    }
    
    // MARK: - Загрузка продуктов из Paywall
    func fetchAdaptyProducts() {
        // Запрашиваем Paywall
        Adapty.getPaywall(placementId: premiumAccessLevel) { result in
            switch result {
            case .success(let paywall):
                // Загружаем продукты
                Adapty.getPaywallProducts(paywall: paywall) { productResult in
                    switch productResult {
                    case .success(let products):
                        // Формируем модель продуктов локально
                        let productModel = ProductModel(
                            monthly: products.first(where: { $0.vendorProductId == "monthly" }),
                            yearly: products.first(where: { $0.vendorProductId == "yearly" }),
                            weeklyTrial: products.first(where: { $0.vendorProductId == "weeklyTrial" }),
                            weekly: products.first(where: { $0.vendorProductId == "weekly" })
                        )
                        
                        // Обновляем состояние в главном потоке
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            self.products = [productModel]
                            print("Продукты успешно загружены: \(self.products)")
                        }
                        
                    case .failure(let error):
                        print("Ошибка получения продуктов: \(error.localizedDescription)")
                    }
                }
                
            case .failure(let error):
                print("Ошибка загрузки paywall: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Покупка подписки
    func purchaseSubscription(type: SubscriptionType) {
        guard let model = products.first else {
            print("Продукты не загружены")
            return
        }
        
        let product: AdaptyPaywallProduct?
        switch type {
        case .monthly:
            product = model.monthly
        case .yearly:
            product = model.yearly
        case .weeklyTrial:
            product = model.weeklyTrial
        case .weekly:
            product = model.weekly
        }
        
        guard let validProduct = product else {
            print("Продукт с типом \(type.rawValue) не найден")
            return
        }
        
        Task {
            do {
                let purchaseResult = try await Adapty.makePurchase(product: validProduct)
                let profile = try await Adapty.getProfile()
                
                if profile.accessLevels[premiumAccessLevel]?.isActive == true {
                    print("Подписка активирована!")
                    DispatchQueue.main.async {
                        self.subscriptionStatus = true
                    }
                }
            } catch {
                print("Ошибка покупки: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Восстановление покупок
    func restorePurchases() {
        Task {
            do {
                let profile = try await Adapty.restorePurchases()
                if profile.accessLevels[premiumAccessLevel]?.isActive == true {
                    print("Покупки восстановлены!")
                    DispatchQueue.main.async {
                        self.subscriptionStatus = true
                    }
                }
            } catch {
                print("Ошибка восстановления: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Проверка триала
    func hasTrial() -> Bool {
        guard let model = products.first else { return false }
        return model.weeklyTrial != nil
    }
}
