import UIKit

final class ScanViewModel: ObservableObject {
    private let converterService: ConverterService = .shared
    
    func addImages(images: [UIImage]) {
        converterService.addImages(images: images)
    }
}
