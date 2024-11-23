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
                    .transition(.move(edge: .bottom))
            case .tabBar:
                tabBar()
            case .settings:
                SettingsView(backAction: { selectView(.tabBar) }, 
                             paywallAction: { selectView(.paywall) })
                    .transition(.move(edge: .trailing))
            case .scan:
                ScanView(mainAction: { selectView(.tabBar) },
                         converterAction: { selectView(.converter) })
            case .converter:
                ConverterView(backAction: { selectView(.tabBar) }, 
                              openViewerAction: { selectView(.pdfViewer) }, 
                              openHistoryAction: {
                    selectView(.tabBar)
                    coordinator.tabBarState = 1
                })
            case .pdfViewer:
                PDFViewer(onClose: {
                    selectView(.tabBar)
                    coordinator.tabBarState = 1
                })
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
            MainView(viewModel: .init(scanAction: { selectView(.scan) }),
                     settingsAction: { selectView(.settings) },
                     converterAction: { selectView(.converter) })
            .tabItem {
                Image(.convert)
                
                Text("Convert")
            }
            .tag(0)
            
            HistoryView(backAction: { coordinator.tabBarState = 0 }, 
                        pdfViverAction: { selectView(.pdfViewer) }, 
                        paywallAction: { selectView(.paywall) })
                .tabItem {
                    Image(.history)
                    
                    Text("History")
                }
                .tag(1)
        }
        .accentColor(.customMain)
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
