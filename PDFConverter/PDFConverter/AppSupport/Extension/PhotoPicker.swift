import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    var completion: ([UIImage]) -> Void  // Замыкание для возврата изображений
    var closeCompletion: () -> Void     // Замыкание для обработки закрытия
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 0
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            var images = [UIImage]()
            let group = DispatchGroup()  // Для синхронизации загрузки всех изображений
            
            for result in results {
                let provider = result.itemProvider
                
                if provider.canLoadObject(ofClass: UIImage.self) {
                    group.enter()  // Начало загрузки изображения
                    provider.loadObject(ofClass: UIImage.self) { image, _ in
                        if let image = image as? UIImage {
                            images.append(image)
                        }
                        group.leave()  // Завершение загрузки
                    }
                }
            }
            
            group.notify(queue: .main) {  // Выполнить после загрузки всех изображений
                self.parent.completion(images)
            }
        }
        
        func pickerDidCancel(_ picker: PHPickerViewController) {
            picker.dismiss(animated: true)
            parent.closeCompletion()  // Вызов замыкания при отмене выбора
        }
    }
}
