import UIKit
import PDFKit
import Combine

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
    let url: URL
    let coverImageData: Data
    
    var coverImage: UIImage? {
        UIImage(data: coverImageData)
    }
    
    init(id: UUID, date: Date, name: String, pages: Int, url: URL, coverImage: UIImage) {
        self.id = id
        self.date = date
        self.name = name
        self.pages = pages
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
    private (set) var pdfItems: [PDFItem] = []
    
    @Published
    private (set) var fileName: String = ""
    
    @Published
    private (set) var currentURL: URL?
    
    private let keyValueStorage: KeyValueStorage
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(keyValueStorage: KeyValueStorage = DefaultsStorage()) {
        self.keyValueStorage = keyValueStorage
        self.pdfItems = (try? keyValueStorage.entity(forKey: .pdfItems)) ?? []
        
        observedPDFItems()
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
        pdfItems.removeAll()
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
            
            let pagesCount = prepareImages.filter { $0.isAppend }.count
            pdfItems.append(PDFItem(id: UUID(), date: Date.now, name: fileName, pages: pagesCount, url: fileURL, coverImage: images.first!))
            currentURL = fileURL
            cleanFileName()
            cleanPrepareImages()
            cleanSelectedImages()
        } else {
            print("Не удалось сохранить PDF")
        }
    }
    
    private func observedPDFItems() {
        $pdfItems
            .sink { [weak self] in
                try? self?.keyValueStorage.set(entity: $0, forKey: .pdfItems)
            }
            .store(in: &cancellables)
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
                url: url,
                coverImage: image
            )
        }
    }
}

