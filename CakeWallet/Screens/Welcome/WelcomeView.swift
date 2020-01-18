import UIKit
import FlexLayout

final class WelcomeView: BaseScrollFlexViewWithBottomSection {
    let titleContainer: UIView
    let bodyContainer: UIView
    let welcomeLabel: UILabel
    let descriptionTextView: UITextView
    let buttonsContiner: UIView
    let createWallet: UIButton
    let recoveryWallet: UIButton
    
    required init() {
        titleContainer = UIView()
        bodyContainer = UIView()
        welcomeLabel = UILabel(fontSize: 32)
        descriptionTextView = UITextView()
        buttonsContiner = UIView()
        createWallet = PrimaryButton(title: NSLocalizedString("create_new", comment: ""))
        recoveryWallet = SecondaryButton(title: NSLocalizedString("restore", comment: ""))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        descriptionTextView.textAlignment = .center
        descriptionTextView.font = .systemFont(ofSize: 20)
        descriptionTextView.textColor = UIColor(red: 126, green: 147, blue: 177)
        descriptionTextView.isEditable = false
        descriptionTextView.layer.masksToBounds = true
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.isScrollEnabled = false
        welcomeLabel.numberOfLines = 0
        welcomeLabel.textAlignment = .center
    }
    
    override func configureConstraints() {
        titleContainer.flex.define { flex in
            flex.addItem(welcomeLabel)
        }
        
        bodyContainer.flex.define { flex in
            flex.addItem(titleContainer)
            flex.addItem(descriptionTextView).marginTop(45)
        }
        
        buttonsContiner.flex.define { flex in
            flex.addItem(createWallet).height(56).marginBottom(25)
            flex.addItem(recoveryWallet).height(56)
        }
        
        rootFlexContainer.flex.justifyContent(.spaceBetween).padding(45, 10, 0, 10).define { flex in
            flex.addItem(bodyContainer) //.marginLeft(47).marginRight(55).marginTop(45)
        }
        
        bottomSectionView.flex.define { flex in
            flex.addItem(buttonsContiner).alignSelf(.center).width(90%)//.marginBottom(20)
        }
    }
}
