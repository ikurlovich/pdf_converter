import Foundation
import Combine

final class OnboardingCoordinator: ObservableObject {
    @Published
    var currentStep: Int = 0
    
    @Published
    private (set) var observeAppConfig = AppConfig.default
    
    private let onFinished: () -> Void
    
    private let appUIService: AppUIService = .shared
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished
        
        observedAppConfig()
    }
    
    func next() {
        currentStep += 1
        
        if currentStep == 3{
            onFinished()
        }
    }
    
    private func observedAppConfig() {
        appUIService
            .$observeAppConfig
            .sink { [weak self] in
                self?.observeAppConfig = $0
            }
            .store(in: &cancellables)
    }
}
