import UIKit
import CakeWalletLib
import CakeWalletCore
import FlexLayout

extension TransactionDescription: CellItem {
    func setup(cell: TransactionUITableViewCell) {
        cell.configure(direction: direction, date: date, isPending: isPending, cryptoAmount: totalAmount, fiatAmount: "")
    }
}


final class DashboardController: BaseViewController<DashboardView>, StoreSubscriber, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    let navigationTitleView = WalletsNavigationTitle()
    weak var dashboardFlow: DashboardFlow?
    private(set) var syncButton: UIBarButtonItem?
    private var transactions: [TransactionDescription] = []
    private var initialHeight: UInt64
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    let store: Store<ApplicationState>
    
    init(store: Store<ApplicationState>, dashboardFlow: DashboardFlow?) {
        self.store = store
        self.dashboardFlow = dashboardFlow
        initialHeight = 0
        super.init()
        tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: "wallet_icon")?.resized(to: CGSize(width: 28, height: 28)),
            selectedImage: UIImage(named: "wallet_selected_icon")?.resized(to: CGSize(width: 28, height: 28))
        )
    }
    
    override func configureBinds() {
        navigationItem.titleView = navigationTitleView
        contentView.transactionsTableView.register(items: [TransactionDescription.self])
        contentView.transactionsTableView.delegate = self
        contentView.transactionsTableView.dataSource = self
        contentView.transactionsTableView.addSubview(refreshControl)
        contentView.receiveButton.addTarget(self, action: #selector(presentReceive), for: .touchUpInside)
        contentView.sendButton.addTarget(self, action: #selector(presentSend), for: .touchUpInside)
        contentView.shortStatusBarView.receiveButton.addTarget(self, action: #selector(presentReceive), for: .touchUpInside)
        contentView.shortStatusBarView.sendButton.addTarget(self, action: #selector(presentSend), for: .touchUpInside)
        contentView.shortStatusBarView.isHidden = true
        updateCryptoIcon(for: store.state.walletState.walletType)
        
        navigationTitleView.switchHandler = { [weak self] in
            self?.dashboardFlow?.change(route: .wallets)
        }
        syncButton = UIBarButtonItem(
            image: UIImage(named: "sync_icon")?
                .withRenderingMode(.alwaysOriginal)
                .resized(to: CGSize(width: 24, height: 24)),
            style: .plain,
            target: self,
            action: #selector(reconnectAction)
        )
        navigationItem.rightBarButtonItem = syncButton
        navigationItem.rightBarButtonItem?.tintColor = Theme.current.bar.tint
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
        onStateChange(store.state)
        contentView.statusView.flex.markDirty()
        contentView.rootFlexContainer.flex.layout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    override func setTitle() {
        title = NSLocalizedString("wallet", comment: "")
    }
    
    // MARK: StoreSubscriber
    
    func onStateChange(_ state: ApplicationState) {
        updateStatus(state.blockchainState.connectionStatus)
        updateCryptoBalance(balance: state.balanceState.balance, unlocked: state.balanceState.unlockedBalance)
        onWalletChange(state.walletState, state.blockchainState)
        updateTransactions(state.transactionsState.transactions)
        updateInitialHeight(state.blockchainState)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transactionItem = transactions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withItem: transactionItem, for: indexPath)
        var needToRound = false
        
        if indexPath.row == 0 {
            cell.layer.masksToBounds = false
            cell.roundCorners([.topLeft, .topRight], radius: 20)
            needToRound = true
        }
        
        if indexPath.row == transactions.count - 1 {
            cell.layer.masksToBounds = false
            cell.roundCorners([.bottomLeft, .bottomRight], radius: 20)
            needToRound = true
        }
        
        if !needToRound {
            cell.layer.mask = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let tx = transactions[indexPath.row]
        presentTransactionDetails(for: tx)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {        
        guard scrollView.contentOffset.y > contentView.cardView.frame.height else {
            contentView.shortStatusBarView.isHidden = true
            return
        }
        
        contentView.shortStatusBarView.isHidden = false
        updateCryptoBalance(balance: store.state.balanceState.balance, unlocked: store.state.balanceState.unlockedBalance)
        contentView.shortStatusBarView.receiveButton.flex.markDirty()
        contentView.shortStatusBarView.sendButton.flex.markDirty()
        contentView.shortStatusBarView.flex.layout()
    }

    private func onWalletChange(_ walletState: WalletState, _ blockchainState: BlockchainState) {
        guard navigationTitleView.title != walletState.name else {
            return
        }
        
        initialHeight = 0
        updateTitle(walletState.name)
        updateCryptoIcon(for: walletState.walletType)
    }
    
    private func updateInitialHeight(_ blockchainState: BlockchainState) {
        guard initialHeight == 0 else {
            return
        }
        
        if case let .syncing(height) = blockchainState.connectionStatus {
            initialHeight = height
        } else {
//            initialHeight = blockchainState.currentHeight
        }
    }
    
    @objc
    private func presentReceive() {
        dashboardFlow?.change(route: .receive)
//        let receiveViewController = ReceiveViewController(store: store, receiveFlow: nil)
//        let navController = UINavigationController(rootViewController: receiveViewController)
//        tabBarController?.presentWithBlur(navController, animated: true)
    }
    
    @objc
    private func presentSend() {
//        let sendController = SendViewController(store: store)
//        let navController = UINavigationController(rootViewController: sendController)
//        tabBarController?.presentWithBlur(navController, animated: true)
        dashboardFlow?.change(route: .send)
    }
    
    private func presentTransactionDetails(for tx: TransactionDescription) {
        let transactionDetailsViewController = TransactionDetailsViewController(transactionDescription: tx)
        let nav = UINavigationController(rootViewController: transactionDetailsViewController)
        tabBarController?.presentWithBlur(nav, animated: true)
    }
    
//    private func presentWallets() {
//        let walletsViewController = WalletsViewController(store: store)
//        let navController = UINavigationController(rootViewController: walletsViewController)
//        walletsViewController.modalPresentationStyle = .overCurrentContext
//        navigationItem.titleView?.isHidden = true
//        walletsViewController.onDismissHandler = { [weak self] in
//            self?.navigationItem.titleView?.isHidden = false
//        }
//        tabBarController?.presentWithBlur(navController, animated: true)
//    }
    
    private func updateSyncing(_ currentHeight: UInt64, blockchainHeight: UInt64) {
        if blockchainHeight < currentHeight || blockchainHeight == 0 {
            store.dispatch(BlockchainActions.fetchBlockchainHeight)
        } else {
            let track = blockchainHeight - initialHeight
            let _currentHeight = currentHeight > initialHeight ? currentHeight - initialHeight : 0
            let remaining = track > _currentHeight ? track - _currentHeight : 0
            guard currentHeight != 0 && track != 0 else { return }
            let val = Float(_currentHeight) / Float(track)
            let prg = Int(val * 100)
            contentView.progressBar.updateProgress(prg)
            contentView.updateStatus(text: NSLocalizedString("blocks_remaining", comment: "")
                + ": "
                + String(remaining)
                + "(\(prg)%)")
        }
    }
    
    private func updateStatus(_ connectionStatus: ConnectionStatus) {
        switch connectionStatus {
        case let .syncing(currentHeight):
            updateSyncing(currentHeight, blockchainHeight: store.state.blockchainState.blockchainHeight)
        case .connection:
            updateStatusConnection()
        case .notConnected:
            updateStatusNotConnected()
        case .startingSync:
            updateStatusstartingSync()
        case .synced:
            updateStatusSynced()
        case .failed:
            updateStatusFailed()
        }
    }
    
    private func updateStatusConnection() {
        contentView.progressBar.updateProgress(0)
        contentView.updateStatus(text: NSLocalizedString("connecting", comment: ""))
        contentView.hideSyncingIcon()
    }
    
    private func updateStatusNotConnected() {
        contentView.progressBar.updateProgress(0)
        contentView.updateStatus(text: NSLocalizedString("not_connected", comment: ""))
        contentView.hideSyncingIcon()
    }
    
    private func updateStatusstartingSync() {
        contentView.progressBar.updateProgress(0)
        contentView.updateStatus(text: NSLocalizedString("starting_sync", comment: ""))
        contentView.hideSyncingIcon()
        contentView.rootFlexContainer.flex.layout()
    }
    
    private func updateStatusSynced() {
        contentView.progressBar.updateProgress(100)
        contentView.updateStatus(text: NSLocalizedString("synchronized", comment: ""))
        contentView.hideSyncingIcon()
    }
    
    private func updateStatusFailed() {
        contentView.progressBar.updateProgress(0)
        contentView.updateStatus(text: NSLocalizedString("failed_connection_to_node", comment: ""))
        contentView.hideSyncingIcon()
    }
    
    private func updateCryptoBalance(balance: Amount, unlocked: Amount) {
        guard contentView.shortStatusBarView.isHidden else {
            updateShortCryptoBalance(balance)
            return
        }
        
        contentView.balanceTitleLabel.text = NSLocalizedString("full_balance", comment: "")
        contentView.balanceAmountLabel.text = balance.formatted(pretty: true)
        contentView.balanceTitleLabel.flex.markDirty()
        contentView.balanceAmountLabel.flex.markDirty()
        
        contentView.unlockedTitleLabel.text = NSLocalizedString("available_balance", comment: "")
        contentView.unlockedAmountLabel.text = unlocked.formatted(pretty: true)
        contentView.unlockedTitleLabel.flex.markDirty()
        contentView.unlockedAmountLabel.flex.markDirty()
    }
    
    private func updateShortCryptoBalance(_ amount: Amount) {
        contentView.shortStatusBarView.cryptoAmountLabel.text = amount.formatted(pretty: true)
        contentView.shortStatusBarView.cryptoAmountLabel.flex.markDirty()
    }
    
    private func updateTransactions(_ transactions: [TransactionDescription]) {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
        contentView.transactionTitleLabel.isHidden = transactions.count <= 0
        
        guard self.transactions != transactions else {
            return
        }
        
        self.transactions = transactions.sorted(by: {
            return $0.date > $1.date
        })
        
        if self.transactions.count > 0 {
            if contentView.transactionTitleLabel.isHidden {
                contentView.transactionTitleLabel.isHidden = false
            }
        } else if !contentView.transactionTitleLabel.isHidden {
            contentView.transactionTitleLabel.isHidden = true
        }

        UIView.transition(
            with: contentView.transactionsTableView,
            duration: 0.4,
            options: .transitionCrossDissolve,
            animations: { self.contentView.transactionsTableView.reloadData() })
    }
    
    private func updateTitle(_ title: String) {
        if navigationTitleView.title != title {
            navigationTitleView.title = title
        }
    }
    
    private func updateCryptoIcon(for walletType: WalletType) {
        switch walletType {
        case .sumokoin:
            contentView.cryptoIconView.image = UIImage(named: "sumokoin_logo")
        default:
            break
        }
    }
    
    @objc
    private func reconnectAction() {
        let reconnetionAction = CWAlertAction(title: NSLocalizedString("reconnect", comment: "")) { [weak self] action in
            self?.store.dispatch(WalletActions.reconnect)
            action.alertView?.dismiss(animated: true)
        }
        showInfo(title: NSLocalizedString("reconnection", comment: ""), message: NSLocalizedString("reconnect_alert_text", comment: ""), actions: [reconnetionAction, CWAlertAction.cancelAction])
    }
    
    @objc
    private func refresh(_ refreshControl: UIRefreshControl) {
        store.dispatch(TransactionsActions.forceUpdateTransactions)
//        Dispatcher.standart.dispatch(TransactionsActions.standart.forceUpdateTransactions()) {
//            refreshControl.endRefreshing()
//        }
    }
}
