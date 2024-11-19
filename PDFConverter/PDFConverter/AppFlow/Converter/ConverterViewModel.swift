import Foundation
import Combine

final class ConverterViewModel: ObservableObject {
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
