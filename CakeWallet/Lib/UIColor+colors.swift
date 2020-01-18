import UIKit

extension UIColor {
    static var wildDarkBlue: UIColor {
        return UIColor(red: 155, green: 172, blue: 197)
    }
    
    static var wildDarkBlueShadow: UIColor {
        return UIColor(hex: 0x9BACC5)
    }
    
    static var whiteSmoke: UIColor {
        return UIColor(red: 243, green: 245, blue: 248)
    }
    
    static var vividBlue: UIColor {
        return UIColor(red: 0, green: 162, blue: 235)
    }
    
    static var spaceViolet: UIColor {
        return UIColor(red: 34, green: 40, blue: 75)
    }
    
    static var blueBolt: UIColor {
        return UIColor(red: 0, green: 185, blue: 252)
    }
    
    static var greenMalachite: UIColor {
        return UIColor(red: 39, green: 206, blue: 80)
    }
    
    static var lightBlueGrey: UIColor {
        return UIColor(red: 224, green: 233, blue: 246)
    }
    
    static var sumokoinGreen: UIColor {
        return UIColor(hex: 0x5BCA5B)
    }
    
    static var sumokoinGreenDark: UIColor {
        return UIColor(hex: 0x419B41)
    }
    
    static var sumokoinBlack90: UIColor {
        return UIColor(hex: 0x0A0A0A)
    }
    
    static var sumokoinBlack80: UIColor {
        return UIColor(hex: 0x252525)
    }

    static var sumokoinBlack60: UIColor {
        return UIColor(hex: 0x313131)
    }
    
    static var sumokoinBlack50: UIColor {
        return UIColor.sumokoinBlack60.lighterColor(percent: 0.35)
    }
    
    static var sumokoinBlack40: UIColor {
        return UIColor.sumokoinBlack50.lighterColor(percent: 0.2)
    }
}
