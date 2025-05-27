import SwiftUI

struct BackGestureModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width > 100 {
                            action()
                        }
                    }
            )
    }
}

extension View {
    func backGesture(action: @escaping () -> Void) -> some View {
        self.modifier(BackGestureModifier(action: action))
    }
}
