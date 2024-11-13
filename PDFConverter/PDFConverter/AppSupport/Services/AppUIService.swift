import FirebaseRemoteConfig

final class AppUIService: ObservableObject {
    static let shared = AppUIService()
    
    @Published
    private (set) var observeAppConfig = AppConfig.default
    @Published
    private(set) var isConfigLoaded = false
    
    init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0

        RemoteConfig.remoteConfig().configSettings = settings
        startToFetch()
    }

    private func startToFetch() {
        RemoteConfig.remoteConfig().fetchAndActivate { [weak self] _, error in
            if error != nil {
                self?.observeAppConfig = AppConfig.default
                self?.isConfigLoaded = true
                return
            }

            let config = AppConfig(remoteConfig: RemoteConfig.remoteConfig())
            self?.observeAppConfig = config
            self?.isConfigLoaded = true
        }
    }
}

struct AppConfig {
    let closeOpacity: Double
    let closeTimer: Int
    let enabledAppRatingRequest: Bool
    let isReview: Bool
}

extension AppConfig {
    static let `default`: Self = .init(
        closeOpacity: 1,
        closeTimer: 0,
        enabledAppRatingRequest: true,
        isReview: true
    )
}

extension AppConfig {
    init(remoteConfig: RemoteConfig) {
        self.closeOpacity = remoteConfig["closeOpacity"].numberValue.doubleValue
        self.closeTimer = remoteConfig["closeTimer"].numberValue.intValue
        self.enabledAppRatingRequest = remoteConfig["enabledAppRatingRequest"].boolValue
        self.isReview = remoteConfig["isReview"].boolValue
    }
}
