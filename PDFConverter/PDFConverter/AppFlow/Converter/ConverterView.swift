import SwiftUI

struct ConverterView: View {
    @StateObject
    private var viewModel = ConverterViewModel()
    
    @State
    private var currentPage: Int = 0
    
    @State
    private var isProgress: Bool = false
    
    let backAction: () -> Void
    let openViewerAction: () -> Void
    let openHistoryAction: () -> Void
    
    var body: some View {
        VStack {
            compositeView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.customMain.ignoresSafeArea())
        .onAppear(perform: viewModel.onAppear)
    }
    
    @ViewBuilder
    private func compositeView() -> some View {
        VStack {
            switch viewModel.view {
            case .converter:
                navigationPanel()
                documentPages()
                convertButton()
            case .loading:
                loadingView()
            case .complete:
                completeView()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customMainBackground)
        .mask(RoundedCorners(radius: 24, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: .bottom)
    }
    
    @ViewBuilder
    private func completeView() -> some View {
        VStack {
            Button(action: openHistoryAction) {
                Text("Cancel")
                    .foregroundStyle(.customMain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 130, weight: .light))
                    .foregroundStyle(.red)
                    .padding(.bottom, 40)
                
                Text("Conversion Complete!")
                    .bold()
                    .foregroundStyle(.black)
                    .font(.system(size: 20))
            }
            .frame(maxHeight: .infinity)
            
            Button(action: openViewerAction) {
                NavigationLabel(text: "View PDF")
            }
            .padding(.bottom)
        }
    }
    
    @ViewBuilder
    private func loadingView() -> some View {
        VStack {
            Text("File to PDF")
                .bold()
                .foregroundStyle(.black)
                .font(.system(size: 20))
                .frame(maxWidth: .infinity)
            
            VStack {
                LottieView("PDFLoading", .autoReverse)
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 30)
                
                Text("Please wait,")
                    .foregroundStyle(.black)
                    .font(.system(size: 20, weight: .medium))
                
                Text("your file is being converted…")
                    .foregroundStyle(.black)
                    .padding(.bottom, 30)
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundStyle(.gray.opacity(0.2))
                        .frame(height: 4)
                        .clipShape(Capsule())
                    
                    GeometryReader { geometry in
                        Rectangle()
                            .foregroundStyle(.customMain)
                            .frame(width: isProgress ? geometry.size.width : 0, height: 4)
                            .clipShape(Capsule())
                            .animation(.easeInOut(duration: 3), value: isProgress)
                    }
                    .frame(height: 4)
                }
                .padding()
            }
            .onAppear {
                withAnimation {
                    isProgress = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    viewModel.view = .complete
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    private func documentPages() -> some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(Array(viewModel.prepareImages.enumerated()), id: \.element.id) { index, item in
                    Image(uiImage: item.image)
                        .resizable()
                        .scaledToFit()
                        .tag(index)
                        .opacity(item.isAppend ? 1 : 0.4)
                        .overlay { addMark(item: item) }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            
            Text("\(currentPage + 1) of \(viewModel.prepareImages.count)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(10)
        }
    }
    
    @ViewBuilder
    private func addMark(item: PrepareImage) -> some View {
        Button(action: { viewModel.toggleIsAppend(for: item.id) }) {
            Image(item.isAppend ? .addActiveMark : .addEmptyMark)
                .resizable()
                .frame(width: 32, height: 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding()
    }
    
    @ViewBuilder
    private func convertButton() -> some View {
        Button {
            viewModel.saveImagesAsPDF()
            viewModel.view = .loading
        } label: {
            NavigationLabel(text: "Convert")
        }
        .padding(.bottom)
    }
    
    @ViewBuilder
    private func navigationPanel() -> some View {
        HStack(alignment: .firstTextBaseline) {
            Button(action: backAction) {
                Text("Cancel")
                    .foregroundStyle(.customMain)
            }
            
            Text("File to PDF")
                .bold()
                .foregroundStyle(.black)
                .font(.system(size: 20))
                .frame(maxWidth: .infinity)
            
            Button(action: backAction) {
                Text("Add")
                    .bold()
                    .foregroundStyle(.customMain)
            }
        }
    }
}

#Preview {
    ConverterView(backAction: {}, openViewerAction: {}, openHistoryAction: {})
}
