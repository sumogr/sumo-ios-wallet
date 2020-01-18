import UIKit

final class WelcomeViewController: BaseViewController<WelcomeView> {
    weak var signUpFlow: SignUpFlow?
    
    init(signUpFlow: SignUpFlow) {
        self.signUpFlow = signUpFlow
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func configureBinds() {
        contentView.createWallet.addTarget(self, action: #selector(createWalletAction), for: .touchUpInside)
        contentView.recoveryWallet.addTarget(self, action: #selector(recoverWalletAction), for: .touchUpInside)
        if let appName = Bundle.main.displayName {
            
            // FIXME: Unnamed constant
            var testnetString = ""
            #if USE_TESTNET
                testnetString = "- Testnet"
            #endif

            contentView.welcomeLabel.text = String(format: NSLocalizedString("welcome", comment: ""), "\(appName)\(testnetString)")
        }
        
        // FIXME: Unnamed constant

        contentView.descriptionTextView.text = NSLocalizedString("starting_creation_selection", comment: "")
    }
    
    @objc
    private func createWalletAction() {
        signUpFlow?.change(route: .setupPin({ signUpFlow  in
            signUpFlow.change(route: .createWallet)
        }))
    }
    
    @objc
    private func recoverWalletAction() {
        signUpFlow?.change(route: .setupPin({ signUpFlow in
            signUpFlow.change(route: .restore)
        }))
    }
}
