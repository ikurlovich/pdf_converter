import SwiftUI

struct AppCoordinatorView: View {
    @ObservedObject
    var coordinator: AppCoordinator
    @StateObject
    private var appUIService = AppUIService.shared
    
    var body: some View {
        if appUIService.isConfigLoaded {
            coordinatorMap()
        } else {
            customPreloader()
        }
    }
    
    @ViewBuilder
    private func coordinatorMap() -> some View {
        VStack {
            switch coordinator.currentView {
            case .onboarding(let c):
                OnboardingView(coordinator: c)
            case .paywall:
                PaywallView(closeAction: { selectView(.tabBar) })
            case .tabBar:
                tabBar()
            case .settings:
                SettingsView(backAction: { selectView(.tabBar) })
                    .transition(.move(edge: .trailing))
            }
        }
    }
    
    @ViewBuilder
    private func customPreloader() -> some View {
        VStack {
            Image(.pdfMiniLogo)
                .resizable()
                .frame(width: 120, height: 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customMain)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func tabBar() -> some View {
        TabView(selection: $coordinator.tabBarState) {
            MainView(settingsAction: { selectView(.settings) })
                .tabItem {
                    Image(.convert)
                    
                    Text("Convert")
                }
                .tag(0)
            
            HistoryView(backAction: { coordinator.tabBarState = 0 })
                .tabItem {
                    Image(.history)
                    
                    Text("History")
                }
                .tag(1)
        }
        .background(CustomTabBarAppearance())
    }
    
    private func selectView(_ view: AppCoordinator.ViewState) {
        withAnimation {
            coordinator.selectCurrentView(view)
        }
    }
}

#Preview {
    AppCoordinatorView(coordinator: .init())
}
