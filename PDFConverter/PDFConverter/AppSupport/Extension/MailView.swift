import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    @Binding 
    var isShowing: Bool
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailController = MFMailComposeViewController()
        mailController.setToRecipients([AppInfo.Emails.supportEmail])
        mailController.setSubject("Feedback")
        mailController.setMessageBody("", isHTML: false)
        mailController.mailComposeDelegate = context.coordinator
        return mailController
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding 
        var isShowing: Bool
        
        init(isShowing: Binding<Bool>) {
            _isShowing = isShowing
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            isShowing = false
        }
    }
}

