import SwiftUI
import StoreKit
import MessageUI

struct SettingsView: View {
    let backAction: () -> Void
    
    @Environment(\.requestReview)
    var requestReview
    
    @Environment(\.openURL)
    var openURL
    
    @State
    private var isShowingMailView = false
    @State
    private var isShowAlert = false
    
    let paywallAction: () -> Void
    
    var body: some View {
        VStack {
            customNavigationPanel()
            settingsItems()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customMain)
        .backGesture(action: backAction)
    }
    
    @ViewBuilder
    private func settingsItems() -> some View {
        VStack {
            settingsBanner()
            
            VStack {
                settingsItem(
                    image: .rate,
                    title: "Rate the App",
                    action: callReview
                )
                
                settingsItem(
                    image: .share,
                    title: "Share the App",
                    action: shareURL
                )
                
                settingsItem(
                    image: .support,
                    title: "Support",
                    action: sendFeedback
                )
                
                settingsItem(
                    image: .privacy,
                    title: "Privacy Policy",
                    action: {
                        openURL(AppInfo.URLs.privacyURL)
                    }
                )
                
                settingsItem(
                    image: .terms,
                    title: "Terms of Use",
                    action: {
                        openURL(AppInfo.URLs.termsURL)
                    }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.customMainBackground)
        .mask(RoundedCorners(radius: 24, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $isShowingMailView) {
            MailView(isShowing: $isShowingMailView)
                .ignoresSafeArea()
        }
        .alert(isPresented: $isShowAlert) {
            Alert(
                title: Text("Unable to Send Email"),
                message: Text("A mail client is not set up on your device.\nI look forward to your suggestions at: test@test.com"),
                dismissButton: .default(Text("OK"))
            )
        }
        
    }
    
    @ViewBuilder
    private func settingsBanner() -> some View {
        Button(action: paywallAction) {
            Image(.settingsBanner)
                .resizable()
                .scaledToFit()
                .padding(.bottom, 10)
        }
    }
    
    @ViewBuilder
    private func settingsItem(
        image: ImageResource,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(image)
                    .resizable()
                    .frame(width: 32, height: 32)
                
                Text(title)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray)
                    .font(.system(size: 18, weight: .medium))
                    .opacity(0.5)
            }
            .foregroundStyle(.black)
            .padding(.horizontal)
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    @ViewBuilder
    private func customNavigationPanel() -> some View {
        ZStack {
            Button(action: backAction) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 26, weight: .medium))
                    .contentShape(Rectangle())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            Text("Settings")
                .bold()
                .font(.title)
        }
        .foregroundStyle(.white)
    }
    
    private func sendFeedback() {
        if MFMailComposeViewController.canSendMail() {
            self.isShowingMailView.toggle()
        } else {
            self.isShowAlert = true
        }
    }
    
    private func callReview() {
        DispatchQueue.main.async {
            requestReview()
        }
    }
    
    private func shareURL() {
        if let url = AppInfo.URLs.shareURL {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                if UIDevice.current.userInterfaceIdiom == .pad {
                    activityViewController.popoverPresentationController?.sourceView = windowScene.windows.first
                    activityViewController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 200, height: 200)
                }
                rootViewController.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
}

#Preview {
    SettingsView(backAction: {}, paywallAction: {})
}
