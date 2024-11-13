import Foundation
import Combine

final class PaywallViewModel: ObservableObject {
    @Published
    var isActiveTrial: Bool = false
    
    @Published
    var isShowCloseButton: Bool = false
    
    @Published
    private (set) var observeAppConfig = AppConfig.default
    
    private let appUIService: AppUIService = .shared
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        observedAppConfig()
    }
    
    func onAppear() {
        startTimer()
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: TimeInterval(observeAppConfig.closeTimer), repeats: false) { [weak self] timer in
            self?.isShowCloseButton = true
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