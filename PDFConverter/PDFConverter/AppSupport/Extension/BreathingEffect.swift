import SwiftUI

extension View {
    func breathingAnimation() -> some View {
        self.modifier(BreathingEffect(scale: 0.95, duration: 0.7))
    }
}

struct BreathingEffect: ViewModifier {
    @State 
    private var isAnimating = false
    
    var scale: CGFloat
    var duration: Double

    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? scale : 1.0)
            .onAppear {
                isAnimating = true
            }
            .animation(
                .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
    }
}
