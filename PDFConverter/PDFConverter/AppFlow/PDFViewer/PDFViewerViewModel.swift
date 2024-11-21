import PDFKit
import UIKit
import Combine

final class PDFViewerViewModel: ObservableObject {
    @Published 
    private(set) var currentURL: URL?
    
    @Published
    private(set) var pdfImages: [UIImage] = []
    
    @Published
    var currentName: String = ""
    
    @Published
    var isShowRenameAlert: Bool = false
    
    @Published
    var isShowDeleteAlert: Bool = false
    
    @Published
    var showingOptions: Bool = false
    
    @Published
    var isCloseActionDisable: Bool = true
    
    var fileName: String {
        currentURL?.deletingPathExtension().lastPathComponent ?? "Error"
    }
    
    private let converterService: ConverterService = .shared
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        observedCurrentURL()
    }
    
    func deleteImages() {
        pdfImages.removeAll()
    }
    
    func activeRenameFile() {
        currentName = fileName
        isShowRenameAlert.toggle()
    }
    
    func renameFile() {
        guard let currentURL = currentURL else { return }
        let newURL = currentURL.deletingLastPathComponent().appendingPathComponent(currentName + ".pdf")
        do {
            try FileManager.default.moveItem(at: currentURL, to: newURL)
            converterService.selectCurrentURL(url: newURL)
            converterService.loadPDFFiles() // Обновление списка файлов
        } catch {
            print("Ошибка при переименовании файла: \(error)")
        }
    }
    
    // 2. Создание дубликата файла
    func createFileCopy() {
        guard let currentURL = currentURL else { return }
        let directory = currentURL.deletingLastPathComponent()
        let originalName = currentURL.deletingPathExtension().lastPathComponent
        var copyIndex = 1
        var copyURL: URL
        
        repeat {
            let copyName = "\(originalName)_copy(\(copyIndex)).pdf"
            copyURL = directory.appendingPathComponent(copyName)
            copyIndex += 1
        } while FileManager.default.fileExists(atPath: copyURL.path)
        
        do {
            try FileManager.default.copyItem(at: currentURL, to: copyURL)
            converterService.loadPDFFiles() // Обновление списка файлов
        } catch {
            print("Ошибка при создании копии файла: \(error)")
        }
    }
    
    // 3. Отправка на печать
    func printFile() {
        guard let currentURL = currentURL else { return }
        let printController = UIPrintInteractionController.shared
        if let data = try? Data(contentsOf: currentURL) {
            let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.outputType = .general
            printInfo.jobName = currentURL.lastPathComponent
            printController.printInfo = printInfo
            printController.printingItem = data
            printController.present(animated: true, completionHandler: nil)
        } else {
            print("Ошибка при открытии файла для печати.")
        }
    }
    
    // 4. Удаление файла
    func activeDeleteFile() {
        isShowDeleteAlert.toggle()
    }
    
    func deleteFile() {
        guard let currentURL = currentURL else { return }
        do {
            try FileManager.default.removeItem(at: currentURL)
            converterService.loadPDFFiles() // Обновление списка файлов
        } catch {
            print("Ошибка при удалении файла: \(error)")
        }
    }
    
    // 5. Шаринг файла
    func shareFile() {
        let usedURL = currentURL!
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            let activityViewController = UIActivityViewController(activityItems: [usedURL], applicationActivities: nil)
            if UIDevice.current.userInterfaceIdiom == .pad {
                activityViewController.popoverPresentationController?.sourceView = windowScene.windows.first
                activityViewController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 200, height: 200)
            }
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func observedCurrentURL() {
        converterService
            .$currentURL
            .sink { [weak self] in
                self?.currentURL = $0
                self?.loadPDFImages()
            }
            .store(in: &cancellables)
    }
    
    private func convertPDFToImages(from url: URL) -> [UIImage]? {
        guard let pdfDocument = PDFDocument(url: url) else { return nil }
        var images: [UIImage] = []
        
        for pageIndex in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else { continue }
            let pageRect = page.bounds(for: .mediaBox)
            let rotation = page.rotation
            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            let image = renderer.image { context in
                let cgContext = context.cgContext
                cgContext.saveGState()
                cgContext.translateBy(x: 0, y: pageRect.size.height)
                cgContext.scaleBy(x: 1.0, y: -1.0)
                
                if rotation != 0 {
                    cgContext.translateBy(x: pageRect.midX, y: pageRect.midY)
                    cgContext.rotate(by: CGFloat(rotation) * .pi / 180)
                    cgContext.translateBy(x: -pageRect.midX, y: -pageRect.midY)
                }

                page.draw(with: .mediaBox, to: cgContext)
                cgContext.restoreGState()
            }
            images.append(image)
        }
        
        return images
    }
    
    private func loadPDFImages() {
        guard let currentURL = currentURL else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            if let images = self.convertPDFToImages(from: currentURL) {
                DispatchQueue.main.async {
                    self.pdfImages = images
                    self.isCloseActionDisable = false
                }
            }
        }
    }
}

