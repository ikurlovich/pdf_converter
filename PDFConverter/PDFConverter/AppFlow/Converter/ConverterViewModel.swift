import Foundation
import Combine

final class ConverterViewModel: ObservableObject {
    enum ViewState {
        case converter, loading, complete
    }
    
    @Published
    var view: ViewState = .converter
    
    @Published
    private (set) var prepareImages: [PrepareImage] = []
    
    private let converterService: ConverterService = .shared
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        observedPrepareImages()
    }
    
    func onAppear() {
        converterService.getPrepareImages()
    }
    
    func toggleIsAppend(for id: UUID) {
        converterService.toggleIsAppend(for: id)
    }
    
    func saveImagesAsPDF() {
        converterService.saveImagesAsPDF()
    }
    
    private func observedPrepareImages() {
        converterService
            .$prepareImages
            .sink { [weak self] in
                self?.prepareImages = $0
            }
            .store(in: &cancellables)
    }
}
