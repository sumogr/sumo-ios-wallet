import Foundation

public enum WalletType {
    case sumokoin, bitcoin
    
    public var currency: CryptoCurrency {
        switch self {
        case .sumokoin:
            return .sumokoin
        case .bitcoin:
            return .bitcoin
        }
    }
    
    public func string() -> String {
        switch self {
        case .bitcoin:
            return "Bitcoin"
        case .sumokoin:
            return "Sumokoin"
        }
    }
}
