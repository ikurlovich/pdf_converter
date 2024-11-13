import Foundation
import PhotosUI
import AVFoundation

final class PermissionsService: ObservableObject {
    func callPhotoLibraryPermission(completion: @escaping () -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                switch status {
                case .notDetermined:
                    break
                case .restricted:
                    break
                case .denied:
                    break
                case .authorized:
                    completion()
                case .limited:
                    completion()
                @unknown default:
                    break
                }
            }
        }
    }
    
    func callCameraPermission(completion: @escaping () -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    completion()
                }
            }
        }
    }
}
