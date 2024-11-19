import SwiftUI
import PDFKit

struct PDFViewer: View {
    @StateObject
    private var viewModel = PDFViewerViewModel()
    
    let historyAction: () -> Void
    
    var body: some View {
        PDFKitView(url: viewModel.currentURL!)
            .edgesIgnoringSafeArea(.all)
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}
