import UIKit

class HomeItemCell: UITableViewCell {

    private var homeItemView: HomeItemView?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        selectionStyle = .none

        let view: HomeItemView = HomeItemView.fromNib()
        contentView.addSubview(view)
        view.pinAllEdgesToParent()
        self.homeItemView = view
    }

    public func setup(viewData: HomeItemViewData) {
        homeItemView?.setup(item: viewData)
    }
}

class HomeItemView: UIView {
    public var onAcknowledged: (() -> Void)?

    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descrLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        notificationView.layer.cornerRadius = 25

        backgroundView.layer.cornerRadius = 15
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 4, height: 4)
        backgroundView.layer.shadowRadius = 4
        backgroundView.layer.shadowOpacity = 0.25
    }

    func setup(item: HomeItemViewData) {
        notificationView.isHidden = item.notification == nil
        notificationLabel.isHidden = item.notification == nil
        notificationLabel.text = item.notification?.text
        titleLabel.text = item.title
        descrLabel.text = item.descr

        if item.notification != nil {
            notificationView.transform = CGAffineTransform(scaleX: 0, y: 0)
            notificationLabel.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping:
                0.6, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: {
                    self.notificationView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.notificationLabel.alpha = 1
            }, completion: nil)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        backgroundView.backgroundColor = .coEpiLightGray
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        backgroundView.backgroundColor = .white
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        backgroundView.backgroundColor = .white
    }
}
