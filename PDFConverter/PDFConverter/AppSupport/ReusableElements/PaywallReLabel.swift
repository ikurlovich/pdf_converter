import SwiftUI

struct PaywallReLabel: View {
    let isActiveTrial: Bool
    
    var body: some View {
        Text(isActiveTrial
             ? "3-day Free Trial then $6.99/week\nAuto renewable. Cancel anytime."
             : "Subscribe for $6.99/week\nAuto renewable. Cancel anytime.")
        .multilineTextAlignment(.center)
        .font(.system(size: 12, weight: .bold))
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
        .breathingAnimation()
    }
}

#Preview {
    PaywallReLabel(isActiveTrial: true)
}
