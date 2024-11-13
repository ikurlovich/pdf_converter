import SwiftUI

@main
struct PDFConverterApp: App {
    @UIApplicationDelegateAdaptor(FirebaseAppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: .init())
                .preferredColorScheme(.light)
        }
    }
}
