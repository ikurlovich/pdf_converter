import SwiftUI

struct OnboardingStep: View {
    let image: ImageResource
    let title: String
    let description: String
    let opacity: Double
    
    var body: some View {
        VStack {
            Image(image)
                .resizable()
                .scaledToFit()
            
            Text(title)
                .font(.system(size: 34, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
                
            Text(description)
                .font(.system(size: 15))
                .multilineTextAlignment(.center)
                .padding(.bottom, 60)
                .opacity(opacity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customMainBackground)
    }
}

#Preview {
    OnboardingStep(
        image: .step1,
        title: "Quick and Easy PDF\nConversion",
        description: "Effortlessly convert documents, photos, and\nscans to PDF format in just a few taps", 
        opacity: 1
    )
}
