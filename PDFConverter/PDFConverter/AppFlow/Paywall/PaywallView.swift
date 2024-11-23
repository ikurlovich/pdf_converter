import SwiftUI

struct PaywallView: View {
    @Environment(\.openURL)
    var openURL
    
    @StateObject
    private var viewModel = PaywallViewModel()
    
    let closeAction: () -> Void
    
    var body: some View {
        VStack {
            VStack {
                paywallImage()
                paywallTitle()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            
            paywallTrialSwitch()
            paywallButton()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.customMainBackground)
        .ignoresSafeArea()
        .onAppear(perform: viewModel.onAppear)
    }
    
    @ViewBuilder
    private func paywallServiceRow() -> some View {
        HStack {
            Group {
                Button {
                    openURL(AppInfo.URLs.termsURL)
                } label: {
                    Text("Terms of use")
                        .foregroundStyle(.black)
                }
                
                Button {
                    viewModel.restorePurchases()
                } label: {
                    Text("Restore")
                        .foregroundStyle(.black)
                }
                
                Button {
                    openURL(AppInfo.URLs.privacyURL)
                } label: {
                    Text("Privacy policy")
                        .foregroundStyle(.black)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .font(.system(size: 12))
        .foregroundStyle(.secondary)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func paywallTrialSwitch() -> some View {
        HStack {
            Text("I want my Free Trial.")
                .foregroundStyle(.black)
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: { viewModel.isActiveTrial.toggle() }) {
                Image(viewModel.isActiveTrial
                      ? .trialActiveMark
                      : .trialEmptyMark)
                .resizable()
                .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .frame(height: 46)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(Capsule())
        .padding()
    }
    
    @ViewBuilder
    private func paywallButton() -> some View {
        VStack {
            Button{
                viewModel.purchaseSubscription()
            } label: {
                if viewModel.observeAppConfig.isReview {
                    PaywallReLabel(isActiveTrial: viewModel.isActiveTrial)
                } else {
                    OnboardingLabel()
                }
            }
            paywallServiceRow()
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
    
    @ViewBuilder
    private func paywallImage() -> some View {
        Image(.paywall)
            .resizable()
            .scaledToFit()
            .overlay {
                if viewModel.isShowCloseButton {
                    Button(action: closeAction) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                            .opacity(viewModel.observeAppConfig.closeOpacity)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(.top, 80)
                            .padding(.leading)
                    }
                    .buttonStyle(.plain)
                }
            }
    }
    
    @ViewBuilder
    private func paywallTitle() -> some View {
        VStack {
            Text("Full access\nto all features")
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .font(.system(size: 34, weight: .bold))
                .padding(.bottom, 5)
            
            Text(viewModel.isActiveTrial
                 ? "Start a 3-day free trial of PDF Converter app with\nno limits just for $6.99/week."
                 : "Start PDF Converter app\nwith no limits just for $6.99/week. ")
            .foregroundStyle(.black)
            .multilineTextAlignment(.center)
            .font(.system(size: 15))
            .opacity(viewModel.observeAppConfig.closeOpacity)
        }
    }
}

#Preview {
    PaywallView(closeAction: {})
}
