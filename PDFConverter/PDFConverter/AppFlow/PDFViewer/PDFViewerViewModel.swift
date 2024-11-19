import Foundation
import Combine

final class PDFViewerViewModel: ObservableObject {
    @Published
    private (set) var currentURL: URL?
    
    private let converterService: ConverterService = .shared
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        observedCurrentURL()
    }
    
    private func observedCurrentURL() {
        converterService
            .$currentURL
            .sink { [weak self] in
                self?.currentURL = $0
            }
            .store(in: &cancellables)
    }
}
