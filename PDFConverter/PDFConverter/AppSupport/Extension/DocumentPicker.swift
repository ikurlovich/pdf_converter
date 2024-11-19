import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    var completion: ([UIImage]) -> Void  // Завершение для возврата изображений
    
    let closeCompletion: () -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.image])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            var images = [UIImage]()
            
            for url in urls {
                print("Selected URL: \(url)")  // Отладка URL
                
                // Проверка на изображение перед загрузкой данных
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    do {
                        let data = try Data(contentsOf: url)
                        if let image = UIImage(data: data) {
                            images.append(image)
                        } else {
                            print("Failed to convert data to UIImage for URL: \(url)")
                        }
                    } catch {
                        print("Error loading image data from URL: \(error.localizedDescription)")
                    }
                } else {
                    print("Failed to access security scoped resource for URL: \(url)")
                }
            }
            
            print("Total images loaded: \(images.count)")
            parent.completion(images)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.closeCompletion()
        }
    }
}
