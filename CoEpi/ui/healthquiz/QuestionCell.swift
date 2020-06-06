import UIKit

class QuestionCell: UITableViewCell {
    public var onChecked: ((Question, Bool) -> ())?

    private let checkBox: CheckBox = .init()
    private var question: Question?
    private var customFont: UIFont!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        checkBox.onChecked = { [weak self] (checked: Bool) -> Void in
            guard let this = self, let q = this.question else { return }
            this.onChecked?(q, checked)
        }
        accessoryView = checkBox

        textLabel?.font = UIFontMetrics.default.scaledFont(for: Fonts.robotoRegular)
        textLabel?.adjustsFontForContentSizeCategory = true
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setQuestion(question: Question) {
        self.question = question
        textLabel?.text = question.text
        checkBox.isChecked = question.checked
    }
}

class CheckBox: UIButton {
    public var onChecked: ((Bool) -> ())?

    let checkedImage = UIImage(named: "checkbox_checked")
    let uncheckedImage = UIImage(named: "checkbox_unchecked")

    init() {
        super.init(frame: .zero)

        addTarget(self, action:#selector(buttonClicked(sender:)), for: .touchUpInside)
        isChecked = false
        
        guard checkedImage?.size == uncheckedImage?.size, let size = checkedImage?.size else { return }
        self.frame.size = size
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isChecked: Bool = false {
        didSet {
            if isChecked {
                setImage(checkedImage, for: .normal)
            } else {
                setImage(uncheckedImage, for: .normal)
            }
        }
    }

    @objc func buttonClicked(sender: UIButton) {
        isChecked = !isChecked
        onChecked?(isChecked)
    }
}
