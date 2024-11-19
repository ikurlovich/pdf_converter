import SwiftUI
import StoreKit

struct OnboardingView: View {
    @ObservedObject
    var coordinator: OnboardingCoordinator
    
    @Environment(\.requestReview)
    var requestReview
    
    @State 
    private var reviewRequested = false

    var body: some View {
        VStack {
            TabView(selection: $coordinator.currentStep) {
                OnboardingStep(
                    image: .step1,
                    title: "Quick and Easy PDF\nConversion",
                    description: "Effortlessly convert documents, photos, and\nscans to PDF format in just a few taps", 
                    opacity: coordinator.observeAppConfig.closeOpacity
                )
                .tag(0)
                .contentShape(Rectangle())
                .simultaneousGesture(DragGesture())
                
                OnboardingStep(
                    image: .step2,
                    title: "Flexible Import\nOptions",
                    description: "Choose from file upload, gallery photos, or\ncamera scanning for seamless access", 
                    opacity: coordinator.observeAppConfig.closeOpacity
                )
                .tag(1)
                .contentShape(Rectangle())
                .simultaneousGesture(DragGesture())
                .onAppear(perform: callReview)
                
                OnboardingStep(
                    image: .step3,
                    title: "Organized PDF File\nHistory",
                    description: "Conveniently access and manage all your\nconverted PDF files in one organized place", 
                    opacity: coordinator.observeAppConfig.closeOpacity
                )
                .tag(2)
                .contentShape(Rectangle())
                .simultaneousGesture(DragGesture())
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            .animation(.default, value: coordinator.currentStep)
            
            Button(action: coordinator.next) {
                OnboardingLabel()
                    .breathingAnimation()
            }
            .padding(.horizontal)
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customMainBackground)
    }
    
    private func callReview() {
        if coordinator.observeAppConfig.isReview && !reviewRequested {
            requestReview()
            reviewRequested = true
        }
    }
    
}

#Preview {
    OnboardingView(coordinator: .init(onFinished: {}))
}
