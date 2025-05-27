import SwiftUI
import Firebase
import Adapty

class MainAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        Adapty.activate(AppInfo.SDKAdapty.apiKey)
        
        return true
    }
}
