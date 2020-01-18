import UIKit

class FlexCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        configureConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        let selectionColor = UIView() as UIView
        selectionColor.backgroundColor = Theme.current.tableCell.selected
        selectedBackgroundView = selectionColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.pin.width(size.width)
        layout()
        let size = contentView.frame.size
        return size
    }
    
    func layout() {
        contentView.flex.layout(mode: .adjustHeight)
    }
}
