import Foundation
import CakeWalletLib
import CWMonero

final class Configurations {
    enum DefaultsKeys: Stringify {
        case nodeUri, nodeLogin, nodePassword, currentWalletName,
        currentWalletType, biometricAuthenticationOn, passwordIsRemembered, transactionPriority,
        currency, defaultNodeChanged, autoSwitchNode, pinLength, currentTheme, termsOfUseXMRto, termsOfUseMorph
        
        func string() -> String {
            switch self {
            case .nodeUri:
                return "node_uri"
            case .nodeLogin:
                return "node_login"
            case .nodePassword:
                return "node_password"
            case .currentWalletName:
                return "current_wallet_name"
            case .currentWalletType:
                return "current_wallet_type"
            case .biometricAuthenticationOn:
                return "biometric_authentication_on"
            case .passwordIsRemembered:
                return "pin_password_is_remembered"
            case .transactionPriority:
                return "saved_fee_priority"
            case .currency:
                return "currency"
            case .defaultNodeChanged:
                return "default_node_was_changed"
            case .autoSwitchNode:
                return "auto_switch_node"
            case .pinLength:
                return "pin-length"
            case .currentTheme:
                return "current-theme"
            case .termsOfUseXMRto:
                return "terms_of_use_xmrto_accepted"
            case .termsOfUseMorph:
                return "terms_of_use_morph_accepted"
            }
        }
    }
    static var defaultMoneroNode: MoneroNodeDescription {
        #if USE_TESTNET
            NSLog("USING TESTNET NODE")
            return MoneroNodeDescription(uri: "167.172.44.84:29734")
        #endif
      
        return MoneroNodeDescription(uri: "167.172.44.84:19734")
    }

    static let preDefaultNodeUri = "167.172.44.84:19734"
    
    static let donactionAddress = "Sumoo64zh7dRFyB8dgDWZMLmzKBgGXYWZCG4NBF2VcvzEuiSQpMjyyiYJ1Ra696pZu56PPFQNBDdB1rZjyeX1RVKeWZgHg7pTxj"
}
