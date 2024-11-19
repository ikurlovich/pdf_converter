import Foundation
import Combine

final class HistoryViewModel: ObservableObject {
    @Published
    private (set) var pdfItems: [PDFItem] = []
    
    private let converterService: ConverterService = .shared
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        observedPDFItems()
    }
    
    func selectCurrentURL(url: URL) {
        converterService.selectCurrentURL(url: url)
    }
    
    private func observedPDFItems() {
        converterService
            .$pdfItems
            .sink { [weak self] in
                self?.pdfItems = $0
            }
            .store(in: &cancellables)
    }
}
