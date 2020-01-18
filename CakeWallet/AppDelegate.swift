import UIKit
import CakeWalletLib
import CakeWalletCore
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var signUpFlow: SignUpFlow?
    var walletFlow: WalletFlow?
    var rememberedViewController: UIViewController?
    private var blurEffectView: UIVisualEffectView?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        do {
            try migrateKeychainAccessibilities(keychain: KeychainStorageImpl.standart)
        } catch {
            print("migrateKeychainAccessibilities Error")
            print(error)
        }
        
        IQKeyboardManager.shared.enable = true
        register(handler: LoadWalletHandler())
        register(handler: LoadCurrentWalletHandler())
        register(handler: CreateWalletHandler())
        register(handler: RestoreFromKeysWalletHandler())
        register(handler: RestoreFromSeedWalletHandler())
        register(handler: FetchBlockchainHeightHandler())
        register(handler: CalculateEstimatedFeeHandler())
        register(handler: FetchWalletsHandler())
        register(handler: UpdateTransactionsHandler())
        register(handler: UpdateTransactionHistoryHandler())
        register(handler: ForceUpdateTransactionsHandler())
        register(handler: ConnectToNodeHandler())
        register(handler: ReconnectToNodeHandler())
        register(handler: SaveHandler())
        register(handler: CreateTransactionHandler())
        register(handler: CommitTransactionHandler())
        register(handler: RescanHandler())
        register(handler: FetchSeedHandler())
        register(handler: SetPinHandler())
        register(handler: ChangeAutoSwitchHandler())
        register(handler: ChangeTransactionPriorityHandler())
        register(handler: ChangeCurrentNodeHandler())
        register(handler: ChangeCurrentFiatHandler())
        register(handler: CheckConnectionHandler())
        register(handler: UpdateFiatPriceHandler())
        register(handler: UpdateFiatBalanceHandler())
        register(handler: UpdateSubaddressesHandler())
        register(handler: UpdateSubaddressesHistroyHandler())
        register(handler: AddNewSubaddressesHandler())
        register(handler: ChangeBiometricAuthenticationHandler())
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let pin = try? KeychainStorageImpl.standart.fetch(forKey: .pinCode)

        if !store.state.walletState.name.isEmpty && pin != nil {
            let authController = AuthenticationViewController(store: store, authentication: AuthenticationImpl())

            authController.handler = { [weak authController] in
                DispatchQueue.main.async {
                    store.dispatch(SettingsState.Action.isAuthenticated)
                    authController?.showSpinner(withTitle: NSLocalizedString("loading_wallet", comment: "")) { alert in
                        let handler = LoadCurrentWalletHandler() //fixme
                        handler.handle(action: WalletActions.loadCurrentWallet, store: store, handler: { action in
                            guard let action = action else {
                                return
                            }

                            if
                                let action = action as? ApplicationState.Action,
                                case let .changedError(_error) = action,
                                let error = _error {
                                alert.dismiss(animated: true) {
                                    authController?.showError(error: error)
                                }
                                return
                            }

                            if let action = action as? WalletState.Action, case .loaded(_) = action {
                                alert.dismiss(animated: true) { [weak self] in
                                    self?.walletFlow = WalletFlow()
                                    self?.walletFlow?.change(route: .start)
                                    
                                    self?.window?.rootViewController = self?.walletFlow?.rootController
                                }
                            }

                            store.dispatch(action)
                        })
                    }
                }
            }
            window?.rootViewController = authController
        } else {
            signUpFlow = SignUpFlow(navigationController: UINavigationController())
            signUpFlow?.doneHandler = { [weak self] in
                self?.walletFlow = WalletFlow()
                self?.walletFlow?.change(route: .start)
                self?.window?.rootViewController = self?.walletFlow?.rootController
                self?.signUpFlow = nil
            }
            window?.rootViewController = signUpFlow?.rootController
            signUpFlow?.change(route: .welcome)
        }

        window?.makeKeyAndVisible()
        setAppearance()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        guard
            let viewController = window?.rootViewController,
            !biometricIsShown && self.blurEffectView == nil else {
                return
        }
        guard
            let _ = window?.rootViewController,
            self.blurEffectView == nil else {
                return
        }

        let vc: UIViewController

        if let presentedVC = viewController.presentedViewController {
            vc = presentedVC
        } else {
            vc = viewController
        }

        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.blurEffectView = blurEffectView
        blurEffectView.frame = vc.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.view.addSubview(blurEffectView)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        guard
            walletFlow != nil
                && !store.state.walletState.name.isEmpty
                && !(UIApplication.topViewController() is AuthenticationViewController) else {
            return
        }
        
        let authScreen = AuthenticationViewController(store: store, authentication: AuthenticationImpl())
        authScreen.modalPresentationStyle = .overFullScreen
        UIApplication.topViewController()?.present(authScreen, animated: false)
        authScreen.handler = { [weak authScreen] in
            DispatchQueue.main.async {
                authScreen?.dismiss(animated: true)
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if let blurEffectView = self.blurEffectView {
            blurEffectView.removeFromSuperview()
            self.blurEffectView = nil
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    private func setAppearance() {
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
        UITabBar.appearance().tintColor = Theme.current.bar.tint
        UITabBar.appearance().unselectedItemTintColor = UIColor(hex: 0xC0D4E2)
        UITabBar.appearance().barTintColor = Theme.current.bar.barTint
//        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = Theme.current.bar.tint // FIX-ME: Unnamed constant
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: Theme.current.bar.text,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)
        ]
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
