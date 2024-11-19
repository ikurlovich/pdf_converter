import SwiftUI

struct MainView: View {
    @ObservedObject
    var viewModel: MainViewModel
    
    @State
    private var scannedImages: [UIImage] = []
    
    let settingsAction: () -> Void
    let converterAction: () -> Void
    
    var body: some View {
        VStack {
            customNavigationPanel()
            mainButtons()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customMain)
        .sheet(isPresented: $viewModel.isPhotoPickerPresented) {
            PhotoPicker(
                completion: { images in
                    viewModel.addImages(images: images)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        converterAction()
                    }
                },
                closeCompletion: {}
            )
            .ignoresSafeArea()
            .onDisappear { print("+\(scannedImages)") }
        }
        .sheet(isPresented: $viewModel.isFilePickerPresented) {
            DocumentPicker(
                completion: { images in
                    viewModel.addImages(images: images)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        converterAction()
                    }
                },
                closeCompletion: {}
            )
            .ignoresSafeArea()
            .onDisappear { print("+\(scannedImages)") }
        }
    }
    
    @ViewBuilder
    private func mainButtons() -> some View {
        VStack {
            VStack(spacing: 15) {
                mainMenuItem(
                    image: .camera,
                    title: "Scan",
                    description: "Open Camera",
                    action: viewModel.scannerAction
                )
                
                HStack(spacing: 15) {
                    mainMenuItem(
                        image: .folder,
                        title: "Files",
                        description: "Open File Manager",
                        action: viewModel.filesAction
                    )
                    
                    mainMenuItem(
                        image: .gallery,
                        title: "Gallery",
                        description: "Open Photo Gallery",
                        action: viewModel.galleryAction
                    )
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customMainBackground)
        .mask(RoundedCorners(radius: 24, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: .bottom)
    }
    
    @ViewBuilder
    private func mainMenuItem(
        image: ImageResource,
        title: String,
        description: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack {
                Image(image)
                    .resizable()
                    .frame(width: 44, height: 44)
                    .padding(.bottom, 10)
                
                VStack(spacing: 5) {
                    Text(title)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.black)
                    
                    Text(description)
                        .font(.system(size: 15))
                        .foregroundStyle(.gray)
                }
            }
            .frame(height: 159)
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(.black)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    @ViewBuilder
    private func customNavigationPanel() -> some View {
        ZStack {
            Button(action: settingsAction) {
                Image(systemName: "gearshape")
                    .resizable()
                    .frame(width: 21, height: 21)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .padding(.bottom, 20)
            
            VStack {
                Text("PDF Converter")
                    .bold()
                    .font(.title)
                
                Text("Easily convert your files to PDF")
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(.white)
        .padding(.bottom, 30)
    }
}

#Preview {
    MainView(
        viewModel: .init(scanAction: {}),
        settingsAction: {},
        converterAction: {}
    )
}
