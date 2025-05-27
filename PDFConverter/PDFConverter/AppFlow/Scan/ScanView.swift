import SwiftUI

struct ScanView: View {
    @StateObject
    private var viewModel = ScanViewModel()
    
    let mainAction: () -> Void
    let converterAction: () -> Void
    
    var body: some View {
        VStack {
            ScannerView(
                completion: { images in
                    viewModel.addImages(images: images)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        converterAction()
                    }
                },
                closeCompletion: mainAction
            )
            .accentColor(.white)
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    ScanView(mainAction: {}, converterAction: {})
}
