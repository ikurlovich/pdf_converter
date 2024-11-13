import SwiftUI

struct NavigationLabel: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(.white)
            .frame(height: 64)
            .frame(maxWidth: .infinity)
            .background(.customMain)
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationLabel(text: "Start")
}
