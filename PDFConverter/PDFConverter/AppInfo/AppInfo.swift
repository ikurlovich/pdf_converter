import Foundation

struct AppInfo {
    struct URLs {
        static let termsURL = URL(string: "http://apple.com")!
        static let privacyURL = URL(string: "http://apple.com")!
        static let shareURL = URL(string: "https://apps.apple.com")
    }
    
    struct Emails {
        static let supportEmail: String = "test.test.com"
    }
    
    struct SDKAdapty {
        static let apiKey: String = "YOUR_ADAPTY_API_KEY"
        static let productId: String = "weekly_subscription_6_99"
        static let accessLevel: String = "premium"
    }
}
