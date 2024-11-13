import Foundation

final class MainViewModel: ObservableObject {
    @Published
    var isPhotoPickerPresented = false
    
    @Published
    var isFilePickerPresented = false
    
    @Published
    var isCameraPresented = false
    
    private let permissionsService = PermissionsService()
    
    func galleryAction() {
        permissionsService.callPhotoLibraryPermission {
            self.isPhotoPickerPresented.toggle()
        }
    }
    
    func filesAction() {
        isFilePickerPresented.toggle()
    }
    
    func cameraAction() {
        permissionsService.callCameraPermission {
            self.isCameraPresented.toggle()
        }
    }
}
