import SwiftUI
import PDFKit

struct PDFViewer: View {
    @StateObject
    private var viewModel = PDFViewerViewModel()
    
    @State
    private var currentPage: Int = 0
    
    let onClose: () -> Void // Закрытие представления
    
    var body: some View {
        VStack {
            compositeView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.customMain.ignoresSafeArea())
        .alert("Rename", isPresented: $viewModel.isShowRenameAlert) {
            TextField("File Name", text: $viewModel.currentName)
            Button("Cancel", action: { viewModel.isShowRenameAlert.toggle() })
            Button("Save", action: viewModel.renameFile)
        } message: {
            Text("Enter a new name for your PDF file.")
        }
        .alert("Delete File", isPresented: $viewModel.isShowDeleteAlert) {
            Button("Delete", role: .destructive, action: viewModel.deleteFile)
        } message: {
            Text("Are you sure you want to delete this PDF file? This action cannot be undone.")
        }
        .confirmationDialog("", isPresented: $viewModel.showingOptions, titleVisibility: .hidden) {
            Button("Rename") {
                viewModel.activeRenameFile()
            }
            
            Button("Share") {
                viewModel.shareFile()
            }
            
            Button("Duplicate") {
                viewModel.createFileCopy()
            }
            
            Button("Print") {
                viewModel.printFile()
            }
            
            Button(role: .destructive) {
                viewModel.activeDeleteFile()
                onClose()
            } label: {
                Text("Delete")
            }
        }
    }
    
    @ViewBuilder
    private func compositeView() -> some View {
        VStack {
            navigationPanel()
            documentPages()
            convertButton()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customMainBackground)
        .mask(RoundedCorners(radius: 24, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: .bottom)
    }
    
    @ViewBuilder
    private func documentPages() -> some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(Array(viewModel.pdfImages.enumerated()), id: \.offset) { index, item in
                    Image(uiImage: item)
                        .resizable()
                        .scaledToFit()
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            
            Text("\(currentPage + 1) of \(viewModel.pdfImages.count)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(10)
        }
    }
    
    @ViewBuilder
    private func convertButton() -> some View {
        Button {
            viewModel.shareFile()
        } label: {
            NavigationLabel(text: "Share")
        }
        .padding(.bottom)
    }
    
    @ViewBuilder
    private func navigationPanel() -> some View {
        HStack(alignment: .firstTextBaseline) {
            Button{
                onClose()
                viewModel.deleteImages()
            } label: {
                Text("Cancel")
                    .foregroundStyle(.customMain)
            }
            .disabled(viewModel.isCloseActionDisable)
            
            Text(viewModel.fileName)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundStyle(.black)
                .font(.system(size: 20))
                .frame(maxWidth: .infinity)
            
            Button {
                viewModel.showingOptions = true
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.customMain)
                    .padding(.bottom, 30)
            }
        }
    }
}

