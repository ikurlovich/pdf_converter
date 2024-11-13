import Foundation

final class AppCoordinator: ObservableObject {
    enum ViewState {
        case onboarding(OnboardingCoordinator), paywall, tabBar, settings
    }
    
    @Published
    var tabBarState = 0
    
    @Published
    private (set) var currentView: ViewState = .tabBar
    
    private let keyValueStorage: KeyValueStorage
    
    private var isOnboardingShown: Bool
    
    init(keyValueStorage: KeyValueStorage = DefaultsStorage()) {
        self.keyValueStorage = keyValueStorage
        self.isOnboardingShown = keyValueStorage.bool(forKey: .isOnboardingShown)
        
        onAppear()
    }
    
    func selectCurrentView(_ view: ViewState) {
        currentView = view
    }
    
    private func onAppear() {
        if isOnboardingShown {
            currentView = .paywall
        } else {
            showOnboarding()
        }
    }
    
    private func showOnboarding() {
        let coordinator = OnboardingCoordinator(onFinished: { [weak self] in
            guard let self else { return }
            
            currentView = .paywall
            isOnboardingShown = true
            keyValueStorage.set(isOnboardingShown, forKey: .isOnboardingShown)
        })
        
        currentView = .onboarding(coordinator)
    }
}
