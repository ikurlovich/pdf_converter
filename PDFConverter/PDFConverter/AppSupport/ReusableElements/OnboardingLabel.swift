import SwiftUI

struct OnboardingLabel: View {
    var body: some View {
        Text("Continue")
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(.white)
            .frame(height: 64)
            .frame(maxWidth: .infinity)
            .background(.customMain)
            .clipShape(Capsule())
            .overlay {
                ZStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.white)
                        
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.customMain)
                        .font(.system(size: 17, weight: .medium))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
            }
    }
}

#Preview {
    OnboardingLabel()
}
