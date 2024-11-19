import SwiftUI

@main
struct PDFConverterApp: App {
    @UIApplicationDelegateAdaptor(FirebaseAppDelegate.self) var delegate
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.darkGray
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
    }
    
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: .init())
                .preferredColorScheme(.dark)
        }
    }
}
