import UIKit

enum Theme: String {
    case def, night
    
    static var current: Theme {
        if
            let rawValue = UserDefaults.standard.string(forKey: Configurations.DefaultsKeys.currentTheme),
            let theme = Theme(rawValue: rawValue) {
            return theme
        }
        
        return .def
    }
    
    var bar: BarColorScheme {
        let darkened = UIColor.sumokoinBlack80.darkerColor(percent: 0.3)
        return BarColorScheme(barTint: darkened, tint: .sumokoinGreen, text: .white)
    }
    
    var container: ContainerColorScheme {
        switch self {
        case .def:
            return ContainerColorScheme(background: .sumokoinBlack80)
        case .night:
            return ContainerColorScheme(background: .wildDarkBlue)
        }
    }
    
    var primaryButton: ButtonColorScheme {
        switch self {
        case .def:
            return ButtonColorScheme(background: .sumokoinGreen, text: .white, shadow: .sumokoinGreenDark)
        case .night:
            return ButtonColorScheme(background: .whiteSmoke, text: .sumokoinGreen, shadow: .sumokoinGreenDark)
        }
    }
    
    var secondaryButton: ButtonColorScheme {
        switch self {
        case .def:
            return ButtonColorScheme(background: .wildDarkBlue, text: .white, shadow: .wildDarkBlueShadow)
        case .night:
            return ButtonColorScheme(background: .whiteSmoke, text: .wildDarkBlue, shadow: .sumokoinGreenDark)
        }
    }
    
    var tertiaryButton: ButtonColorScheme {
        return ButtonColorScheme(background: .sumokoinBlack60, text: .white, shadow: .sumokoinBlack50)
    }
    
    var pin: PinIndicatorScheme {
        return PinIndicatorScheme(background: .sumokoinBlack40, value: .sumokoinGreen, shadow: .sumokoinBlack40)
    }
    
    var pinKey: PinKeyScheme {
        return PinKeyScheme(background: .wildDarkBlue, text: .white, shadow: .wildDarkBlueShadow)
    }
    
    var pinKeyReversed: PinKeyScheme {
        return PinKeyScheme(background: .sumokoinBlack40, text: .white, shadow: .sumokoinBlack40)
    }
    
    var card: CardScheme {
        return CardScheme(background: .sumokoinBlack60, shadow: .sumokoinBlack90)
    }
    
    var text: UIColor {
        switch self {
        case .def:
            return .white
        case .night:
            return .whiteSmoke
        }
    }
    
    var lightText: UIColor {
        switch self {
        case .def:
            return .wildDarkBlue
        case .night:
            return .whiteSmoke
        }
    }
    
    var progressBar: ProgressBarScheme {
        return ProgressBarScheme(value: .greenMalachite, background: .sumokoinBlack40)
    }
    
    var tableCell: CellColorScheme {
        let lighter = UIColor.sumokoinBlack60.lighterColor(percent: 0.3)
        return CellColorScheme(background: .sumokoinBlack60, selected: lighter, text: .white, tint: .sumokoinGreen)
    }
    
    var labelField: LabelFieldScheme {
        return LabelFieldScheme(textColor: .white, titleColor: .wildDarkBlue, selectedTitleColor: .white)
    }
}
