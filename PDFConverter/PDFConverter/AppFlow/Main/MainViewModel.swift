import UIKit

final class MainViewModel: ObservableObject {
    @Published
    var isPhotoPickerPresented = false
    
    @Published
    var isFilePickerPresented = false
    
    private let permissionsService = PermissionsService()
    private let converterService: ConverterService = .shared
    
    let scanAction: () -> Void
    
    init(scanAction:  @escaping () -> Void) {
        self.scanAction = scanAction
    }
    
    func addImages(images: [UIImage]) {
        converterService.addImages(images: images)
    }
    
    func galleryAction() {
        permissionsService.callPhotoLibraryPermission {
            self.isPhotoPickerPresented.toggle()
        }
    }
    
    func filesAction() {
        isFilePickerPresented.toggle()
    }
    
    func scannerAction() {
        permissionsService.callCameraPermission {
            self.scanAction()
        }
    }
}
