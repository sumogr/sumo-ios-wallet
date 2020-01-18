import UIKit
import CakeWalletLib
import CakeWalletCore
import FlexLayout

//fixme
final class TextViewUITableViewCell: FlexCell {
    let textView: UITextView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        textView = UITextView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        configureConstraints()
    }
    
    override func configureView() {
        super.configureView()
        textView.isEditable = false
        contentView.addSubview(textView)
        accessoryType = .none
        backgroundColor = Theme.current.tableCell.background
        textView.backgroundColor = .clear
        textView.textColor = Theme.current.tableCell.text
    }
    
    override func configureConstraints() {
        contentView.flex.addItem(textView).marginLeft(15).width(100%).height(100%)
    }
    
    func configure(attributedText: NSAttributedString) {
        textView.attributedText = attributedText
        textView.flex.markDirty()
        contentView.flex.layout(mode: .adjustHeight)
    }
}


final class SwitchView: BaseView {
    let indicatorView: UIView
    let indicatorImageView: UIImageView
    var isOn: Bool {
        didSet {
            onValueChange(withAnimation: true)
            onChangeHandler?(isOn)
        }
    }
    var onChangeHandler: ((Bool) -> Void)?
    
    convenience init(initialValue: Bool = false) {
        self.init()
        isOn = initialValue
    }
    
    required init() {
        indicatorView = UIView()
        indicatorImageView = UIImageView()
        isOn = false
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 40)))
    }
    
    override func configureView() {
        super.configureView()
        onValueChange(withAnimation: false)
        let onTapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapHandler))
        backgroundColor = .sumokoinBlack40
        layer.masksToBounds = false
        indicatorImageView.layer.masksToBounds = false
        indicatorView.addSubview(indicatorImageView)
        addGestureRecognizer(onTapGesture)
        addSubview(indicatorView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.height * 0.4
        indicatorView.layer.cornerRadius = indicatorImageView.frame.size.height * 0.4
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        onValueChange(withAnimation: false)
    }
    
    @objc
    private func onTapHandler() {
        isOn = !isOn
    }
    
    private func onValueChange(withAnimation isAnimated: Bool) {
        let indicatorFrame: CGRect
        let image: UIImage?
        let backgroundColor: UIColor
        let height = frame.size.height - 10
        let indicatorSize = CGSize(width: height, height: height)
        
        if isOn {
            image = UIImage(named: "check_mark")
            backgroundColor = .sumokoinGreen
            let x = frame.size.width - indicatorSize.width - 5
            indicatorFrame = CGRect(origin: CGPoint(x: x, y: 5), size: indicatorSize) //self.indicatorView.frame.size
        } else {
            image = UIImage(named: "close_icon_white")
            backgroundColor = .wildDarkBlue
            indicatorFrame = CGRect(origin: CGPoint(x: 5, y: 5), size: indicatorSize)
        }
        
        indicatorImageView.image = image
        indicatorImageView.frame = CGRect(origin: CGPoint(x: 7, y: 7), size: CGSize(width: 10, height: 10))
        indicatorView.backgroundColor = backgroundColor
        indicatorView.layer.applySketchShadow(color: backgroundColor, alpha: 0.25, x: 0, y: 5, blur: 14, spread: 5)
        
        if isAnimated {
            UIView.animate(withDuration: 0.5) {
                self.indicatorView.frame = indicatorFrame
            }
        } else {
            self.indicatorView.frame = indicatorFrame
        }
    }
}

final class SettingsViewController: BaseViewController<SettingsView>, UITableViewDelegate, UITableViewDataSource {
    enum SettingsSections: Int {
        case wallets, personal, advanced, support
    }
    
    struct SettingsTextViewCellItem: CellItem {
        let attributedString: NSAttributedString
        
        init(attributedString: NSAttributedString) {
            self.attributedString = attributedString
        }
        
        func setup(cell: TextViewUITableViewCell) {
            cell.configure(attributedText: attributedString)
        }
    }
    
    struct SettingsCellItem: CellItem {
        let title: String
        let action: (() -> Void)?
        let image: UIImage?
        
        init(title: String, image: UIImage? = nil, action: (() -> Void)? = nil) {
            self.title = title
            self.image = image
            self.action = action
        }
        
        func setup(cell: UITableViewCell) {
            cell.backgroundColor = Theme.current.tableCell.background
            cell.textLabel?.textColor = Theme.current.tableCell.text
            cell.textLabel?.text = title
            cell.imageView?.image = image
            
            let arrowRight = UIImage(named: "arrow_right")?
                .resized(to: CGSize(width: 6, height: 10))
                .withRenderingMode(.alwaysTemplate)
            let imageView = UIImageView(image: arrowRight)
            imageView.tintColor = Theme.current.tableCell.tint
            cell.accessoryView = imageView
            
            let selectionColor = UIView() as UIView
            selectionColor.backgroundColor = Theme.current.tableCell.selected
            cell.selectedBackgroundView = selectionColor
        }
    }
    
    final class SettingsSwitchCellItem: CellItem {
        let title: String
        let image: UIImage?
        let action: ((Bool, SettingsSwitchCellItem) -> Void)?
        let switcher: SwitchView = SwitchView()
        
        init(title: String, image: UIImage? = nil, isOn: Bool, action: ((Bool, SettingsSwitchCellItem) -> Void)? = nil) {
            self.title = title
            self.image = image
            self.action = action
            self.switcher.isOn = isOn
            config()
        }
        
        func setup(cell: UITableViewCell) {
            cell.backgroundColor = Theme.current.tableCell.background
            cell.textLabel?.textColor = Theme.current.tableCell.text
            cell.textLabel?.text = title
            cell.imageView?.image = image
            cell.accessoryView = switcher
            switcher.onChangeHandler = { isOn in
                self.action?(isOn, self)
            }
            
            cell.selectionStyle = .none
        }
        
        private func config() {
            switcher.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 35))
        }
    }
    
    struct SettingsPickerCellItem<PickerItem: Formatted>: CellItem {
        let title: String
        let image: UIImage?
        let pickerOptions: [PickerItem]
        let action: ((PickerItem) -> Void)?
        let onFinish: ((PickerItem) -> Void)?
        private var selectedIndex: Int
        
        init(title: String,
             image: UIImage? = nil,
             pickerOptions: [PickerItem],
             selectedAtIndex: Int,
             action: ((PickerItem) -> Void)? = nil,
             onFinish: ((PickerItem) -> Void)? = nil) {
            self.title = title
            self.image = image
            self.action = action
            self.pickerOptions = pickerOptions
            self.selectedIndex = selectedAtIndex
            self.onFinish = onFinish
        }
        
        func setup(cell: SettingsPickerUITableViewCell<PickerItem>) {
            cell.configure(title: title, pickerOptions: pickerOptions, selectedOption: selectedIndex, action: action)
            cell.imageView?.image = image
            cell.onFinish = onFinish
            
            let selectionColor = UIView() as UIView
            selectionColor.backgroundColor = Theme.current.tableCell.selected
            cell.selectedBackgroundView = selectionColor
        }
    }
    
    
    weak var settingsFlow: SettingsFlow?
    
    var transactionPriority: TransactionPriority {
        return store.state.settingsState.transactionPriority
    }
    
    var fiatCurrency: FiatCurrency {
        return store.state.settingsState.fiatCurrency
    }
    
    private let store: Store<ApplicationState>
    private var sections: [SettingsSections: [CellAnyItem]]
    
    init(store: Store<ApplicationState>, settingsFlow: SettingsFlow?) {
        self.store = store
        self.settingsFlow = settingsFlow
        sections = [.wallets: [], .personal: [], .advanced: []]
        super.init()
        tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: "settings_icon")?.resized(to: CGSize(width: 28, height: 28)),
            selectedImage: UIImage(named: "settings_selected_icon")?.resized(to: CGSize(width: 28, height: 28))
        )
    }
    
    override func configureBinds() {
        contentView.table.register(items: [
            SettingsTextViewCellItem.self,
            SettingsCellItem.self,
            SettingsPickerCellItem<TransactionPriority>.self,
            SettingsPickerCellItem<FiatCurrency>.self])
        contentView.table.delegate = self
        contentView.table.dataSource = self
        let transactionPriorities = [
            TransactionPriority.slow,
            TransactionPriority.default,
            TransactionPriority.fast,
            TransactionPriority.fastest]
        
        let fiatCurrencyCellItem = SettingsPickerCellItem<FiatCurrency>(
            title: NSLocalizedString("currency", comment: ""),
            pickerOptions: FiatCurrency.all,
            selectedAtIndex: FiatCurrency.all.index(of: fiatCurrency) ?? 0) { [weak store] currency in
                store?.dispatch(
                    SettingsActions.changeCurrentFiat(currency: currency)
                )
        }
        
        let feePriorityCellItem = SettingsPickerCellItem<TransactionPriority>(
            title: NSLocalizedString("fee_priority", comment: ""),
            pickerOptions: transactionPriorities,
            selectedAtIndex: transactionPriorities.index(of: transactionPriority) ?? 0) { [weak store] priority in
                store?.dispatch(
                    SettingsActions.changeTransactionPriority(priority)
                )
        }
        
        let changePinCellItem = SettingsCellItem(title: NSLocalizedString("change_pin", comment: ""), action: { [weak self] in
            self?.presentChangePin()
        })
        
        let changeLanguage = SettingsCellItem(title: NSLocalizedString("change_language", comment: ""), action: { [weak self] in //fixme
            self?.presentChangeLanguage()
        })
        
        let biometricCellItem = SettingsSwitchCellItem(
            title: NSLocalizedString("allow_biometric_authentication", comment: ""),
            isOn: store.state.settingsState.isBiometricAuthenticationAllowed,
            action: { [weak store] isAllowed, item in
                guard isAllowed != store?.state.settingsState.isBiometricAuthenticationAllowed else {
                    return
                }
                
                store?.dispatch(
                    SettingsActions.changeBiometricAuthentication(isAllowed: isAllowed, handler: { isAllowed in
                        DispatchQueue.main.async {
                            item.switcher.isOn = isAllowed
                        }
                    })
                )
        })
        let rememberPasswordCellItem = SettingsSwitchCellItem(
            title: NSLocalizedString("remember_pin", comment: ""),
            isOn: false // accountSettings.isPasswordRemembered
        ) { [weak self] isOn, item in
            //                self?.accountSettings.isPasswordRemembered = isOn
        }
//        let toggleNightModeCellItem = SettingsSwitchCellItem(
//            title: NSLocalizedString("toggle_night_mode", comment: ""),
//            isOn: Theme.current == .night
//        ) { [weak self] isOn in
//            self?.toggleNightMode(isOn: isOn)
//            //                self?.accountSettings.isPasswordRemembered = isOn
//        }
        let daemonSettingsCellItem = SettingsCellItem(
            title: NSLocalizedString("node_settings", comment: ""),
            action: { [weak self] in
                self?.settingsFlow?.change(route: .nodes)
        })
        sections[.wallets] = [
//            fiatCurrencyCellItem, // DISABLED because we don't need it
            feePriorityCellItem
        ]
        sections[.personal] = [
            changePinCellItem,
            changeLanguage,
            biometricCellItem,
//            rememberPasswordCellItem, // DISABLED because the functionality hasn't been implemented
//            toggleNightModeCellItem
        ]
        sections[.advanced] = [
            daemonSettingsCellItem
        ]
        
        let links = [
            [
                "name": "Website",
                "link": "https://sumokoin.org"
            ],
            [
                "name": "Telegram",
                "link": "https://t.me/joinchat/F8RH2kPmFCnA-igHBKSCAA"
            ],
            [
                "name": "Discord",
                "link": "https://discord.gg/heDXTvP"
            ],
            [
                "name": "Twitter",
                "link": "https://twitter.com/Sumokoin"
            ],
            [
                "name": "Github",
                "link": "https://github.com/sumoprojects/sumokoin-ios-wallet"
            ],
        ]
        
        let linkNames: [String] = links.compactMap { $0["name"] ?? nil }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 5
        paragraphStyle.lineSpacing = 5
        let attributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15),
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.foregroundColor: Theme.current.tableCell.text
        ]
        let attributedString = NSMutableAttributedString(
            string: linkNames.joined(separator: "\n"),
            attributes: attributes)
        
        for link in links {
            guard let name = link["name"], let link = link["link"] else {
                continue;
            }
            
            let nameRange = attributedString.mutableString.range(of: name)
            attributedString.addAttribute(.link, value: link, range: nameRange)
        }
        
        let contactUsCellItem = SettingsTextViewCellItem(attributedString: attributedString)
        sections[.support] = [
            contactUsCellItem,
        ]
        
        if
            let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String {
            contentView.footerLabel.text = String(format: "%@ %@", NSLocalizedString("version", comment: ""), version)
        }
    }
    
    override func setTitle() {
        title = NSLocalizedString("settings", comment: "")
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard
            let section = SettingsSections(rawValue: section),
            let count = sections[section]?.count else {
                return 0
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let section = SettingsSections(rawValue: indexPath.section),
            let item = sections[section]?[indexPath.row] else {
                return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withItem: item, for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard
            let section = SettingsSections(rawValue: indexPath.section),
            !(section == .support && indexPath.row == 0) else { //fixme: hardcoded value!!
                return 145
        }
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //        guard let section = SettingsSections(rawValue: section) else {
        //            return 0
        //        }
        
        //        if section != .donation {
        //            return 50
        //        } else {
        //            return 0
        //        }
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = SettingsSections(rawValue: section) else {
            return nil
        }
        
        let view = UIView(frame:
            CGRect(
                origin: .zero,
                size: CGSize(width: tableView.frame.width, height: 60)))
        let titleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 20, y: 5), size: CGSize(width: view.frame.width - 20, height: view.frame.height)))
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = Theme.current.lightText
        view.backgroundColor =  contentView.backgroundColor
        view.addSubview(titleLabel)
        
        switch section {
        case .personal:
            titleLabel.text = NSLocalizedString("personal", comment: "")
        case .wallets:
            titleLabel.text = NSLocalizedString("wallets", comment: "")
        case .advanced:
            titleLabel.text = NSLocalizedString("advanced", comment: "")
        case .support:
            titleLabel.text = NSLocalizedString("support", comment: "")
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let section = SettingsSections(rawValue: indexPath.section),
            let item = sections[section]?[indexPath.row] as? SettingsCellItem else {
                tableView.deselectRow(at: indexPath, animated: true)
                return
        }

        item.action?()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func presentChangePin() {
        let authViewController = AuthenticationViewController(store: store, authentication: AuthenticationImpl())
        authViewController.handler = { [weak self, weak authViewController] in
            authViewController?.dismiss(animated: false, completion: {
                self?.settingsFlow?.change(route: .changePin)
//                guard let store = self?.store else { return }
//
//                let setupPinViewController = SetupPinViewController(store: store)
//                setupPinViewController.afterPinSetup = { [weak setupPinViewController] in
//                    setupPinViewController?.dismiss(animated: true)
//                }
//                self?.present(UINavigationController(rootViewController: setupPinViewController), animated: true)
            })
        }
        
        present(UINavigationController(rootViewController: authViewController), animated: true)
    }
    
    private func presentChangeLanguage() {
        settingsFlow?.change(route: .changeLanguage)
    }
    
    private func toggleNightMode(isOn: Bool) {
        NotificationCenter.default.post(name: Notification.Name("changeTheme"), object: isOn ? Theme.night : Theme.def)
    }
}
