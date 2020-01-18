import UIKit
import FlexLayout

final class PinCodeView: BaseFlexView {
    let titleLabel: UILabel
    let pinPasswordKeyboard: PinCodeKeyboard
    let pinCodesView: PinCodeIndicatorsView
    
    required init() {
        titleLabel = UILabel.withLightText(fontSize: 24)
        pinPasswordKeyboard = PinCodeKeyboard()
        pinCodesView = PinCodeIndicatorsView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        titleLabel.text = NSLocalizedString("enter_your_pin", comment: "")
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.define { flex in
            flex.addItem(titleLabel).marginTop(20%)
            flex.addItem(pinCodesView).marginTop(25).width(100%).alignItems(.center)
            let pinPasswordKeyboardContainer = UIView()
            pinPasswordKeyboardContainer.flex.justifyContent(.end).grow(1).marginBottom(10.8%).marginTop(25).addItem(pinPasswordKeyboard).marginLeft(10.8%).marginRight(10.8%)
            flex.addItem(pinPasswordKeyboardContainer)
            //            flex.addItem(UIView()).height(10.8%).minHeight(15)
        }
    }
}
