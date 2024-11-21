import PDFKit
import UIKit
import Combine

final class PDFViewerViewModel: ObservableObject {
    @Published 
    private(set) var currentURL: URL?
    
    @Published
    var currentName: String = ""
    
    @Published
    var isShowRenameAlert: Bool = false
    
    @Published
    var isShowDeleteAlert: Bool = false
    
    @Published
    var showingOptions: Bool = false
    
    var fileName: String {
        currentURL?.deletingPathExtension().lastPathComponent ?? "Error"
    }
    
    var filePages: Int {
        guard let url = currentURL, let document = PDFDocument(url: url) else {
            return 0
        }
        return document.pageCount
    }

    private let converterService: ConverterService = .shared
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        observedCurrentURL()
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
            converterService.loadPDFFiles()
        } catch {
            print("Ошибка при переименовании файла: \(error)")
        }
    }
    
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
            converterService.loadPDFFiles()
        } catch {
            print("Ошибка при создании копии файла: \(error)")
        }
    }
    
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
    
    func activeDeleteFile() {
        isShowDeleteAlert.toggle()
    }
    
    func deleteFile() {
        guard let currentURL = currentURL else { return }
        do {
            try FileManager.default.removeItem(at: currentURL)
            converterService.loadPDFFiles()
        } catch {
            print("Ошибка при удалении файла: \(error)")
        }
    }
    
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
            }
            .store(in: &cancellables)
    }
}

