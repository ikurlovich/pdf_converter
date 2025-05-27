import UIKit
import PDFKit

struct PrepareImage {
    let id: UUID
    let image: UIImage
    var isAppend: Bool
}

struct PDFItem: Codable, Equatable {
    let id: UUID
    let date: Date
    let name: String
    let pages: Int
    let weight: Int64
    let url: URL
    let coverImageData: Data
    
    var coverImage: UIImage? {
        UIImage(data: coverImageData)
    }
    
    init(id: UUID, date: Date, name: String, pages: Int, weight: Int64, url: URL, coverImage: UIImage) {
        self.id = id
        self.date = date
        self.name = name
        self.pages = pages
        self.weight = weight
        self.url = url
        self.coverImageData = coverImage.pngData() ?? Data()
    }
}

final class ConverterService {
    static let shared = ConverterService()
    
    @Published
    private (set) var selectedImages: [UIImage] = []
    
    @Published
    private (set) var prepareImages: [PrepareImage] = []
    
    @Published
    private (set) var pdfItems: [PDFItem] = .example
    
    @Published
    private (set) var fileName: String = ""
    
    @Published
    private (set) var currentURL: URL?
    
    private let fileManager = FileManager.default
    
    func loadPDFFiles() {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Не удалось получить путь к директории")
            return
        }
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.creationDateKey, .fileSizeKey], options: .skipsHiddenFiles)
                .filter { $0.pathExtension.lowercased() == "pdf" }
            
            pdfItems = fileURLs.compactMap { processPDF(at: $0) }
        } catch {
            print("Ошибка при чтении директории: \(error)")
        }
    }
    
    private func processPDF(at url: URL) -> PDFItem? {
        guard let pdfDocument = PDFDocument(url: url) else {
            print("Не удалось открыть PDF: \(url.lastPathComponent)")
            return nil
        }
        
        let fileName = url.deletingPathExtension().lastPathComponent
        let coverImage = pdfDocument.page(at: 0)?.thumbnail(of: CGSize(width: 200, height: 300), for: .mediaBox)
        let attributes = try? fileManager.attributesOfItem(atPath: url.path)
        let creationDate = attributes?[.creationDate] as? Date ?? Date()
        let pageCount = pdfDocument.pageCount
        let fileSize = (attributes?[.size] as? Int64 ?? 0) / 1024 // в КБ
        
        guard let coverImage = coverImage else {
            print("Не удалось получить превью для PDF: \(fileName)")
            return nil
        }
        
        return PDFItem(
            id: UUID(),
            date: creationDate,
            name: fileName,
            pages: pageCount,
            weight: fileSize,
            url: url,
            coverImage: coverImage
        )
    }
    
    func addImages(images: [UIImage]) {
        selectedImages.append(contentsOf: images)
        print("---> Add images set \(selectedImages)")
    }
    
    func getPrepareImages() {
        let newPrepareImages = selectedImages.map { PrepareImage(id: UUID(), image: $0, isAppend: true) }
        prepareImages.append(contentsOf: newPrepareImages)
        selectedImages.removeAll()
    }
    
    func toggleIsAppend(for id: UUID) {
        if let index = prepareImages.firstIndex(where: { $0.id == id }) {
            prepareImages[index].isAppend.toggle()
        }
    }
    
    func cleanSelectedImages() {
        selectedImages.removeAll()
    }
    
    func cleanPrepareImages() {
        prepareImages.removeAll()
    }
    
    func cleanFileName() {
        fileName = ""
    }
    
    func cleanHistory() {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Не удалось получить путь к директории")
            return
        }
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                .filter { $0.pathExtension.lowercased() == "pdf" }

            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
            }
            
            pdfItems.removeAll()
            print("История очищена и все файлы удалены")
        } catch {
            print("Ошибка при удалении файлов: \(error)")
        }
    }
    
    func selectCurrentURL(url: URL) {
        currentURL = url
    }
    
    func saveImagesAsPDF() {
        let images = prepareImages.filter { $0.isAppend }.map { $0.image }
        
        guard !images.isEmpty else {
            print("Нет изображений для сохранения")
            return
        }
        
        let fileName = self.fileName.isEmpty ? "Scanned(\(Date.now.formatted()))" : self.fileName
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("\(fileName).pdf")
        
        let pdfDocument = PDFDocument()
        
        for (index, image) in images.enumerated() {
            if let pdfPage = PDFPage(image: image) {
                pdfDocument.insert(pdfPage, at: index)
            }
        }
        
        if pdfDocument.write(to: fileURL) {
            print("PDF сохранен по пути: \(fileURL)")
            currentURL = fileURL
            cleanFileName()
            cleanPrepareImages()
            cleanSelectedImages()
        } else {
            print("Не удалось сохранить PDF")
        }
    }
}

extension Array where Element == PrepareImage {
    static var example: [PrepareImage] {
        (1...3).map { index in
            PrepareImage(id: UUID(), image: UIImage(named: "Example\(index)")!, isAppend: true)
        }
    }
}

extension Array where Element == PDFItem {
    static var example: [PDFItem] {
        (1...3).compactMap { index in
            guard
                let image = UIImage(named: "Example\(index)"),
                let url = URL(string: "https://example.com/document\(index).pdf")
            else {
                return nil
            }
            return PDFItem(
                id: UUID(),
                date: Date.now,
                name: "Scanned(\(Date.now.formatted()))",
                pages: 3,
                weight: 1024,
                url: url,
                coverImage: image
            )
        }
    }
}

