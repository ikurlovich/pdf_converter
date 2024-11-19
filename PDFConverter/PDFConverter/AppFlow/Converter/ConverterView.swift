import SwiftUI

struct ConverterView: View {
    @StateObject
    private var viewModel = ConverterViewModel()

    @State
    private var currentPage: Int = 0
    
    let backAction: () -> Void
    
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
                .padding(.bottom)
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
            backAction()
        } label: {
            NavigationLabel(text: "Convert")
        }
        .padding(.bottom)
    }
    
    @ViewBuilder
    private func navigationPanel() -> some View {
        HStack(alignment: .lastTextBaseline) {
            Button(action: backAction) {
                Text("Cancel")
                    .foregroundStyle(.customMain)
            }
            
            Text("File to PDF")
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
    ConverterView(backAction: {})
}
