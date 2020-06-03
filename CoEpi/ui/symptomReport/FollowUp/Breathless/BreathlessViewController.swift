import UIKit
import RxSwift

class BreathlessViewController: UIViewController {
    private let viewModel: BreathlessViewModel
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var skipButtonLabel: UIButton!
    
    @IBAction func skipButtonAction(_ sender: Any) {
        viewModel.onSkipTap()
    }
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: BreathlessViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
        title = viewModel.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            viewModel.onBack()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_white.png")!)
        
        titleLabel.text = L10n.Ux.Breathless.title
        subtitleLabel.text = L10n.Ux.Breathless.subtitle
        skipButtonLabel.setTitle(L10n.Ux.skip, for: .normal)
        
        
        tableView.register(cellClass: UITableViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 70.0
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let images = ["house", "stop", "ground", "hill", "exercise"]
        
        Observable.just([L10n.Ux.Breathless.p0, L10n.Ux.Breathless.p1, L10n.Ux.Breathless.p2, L10n.Ux.Breathless.p3, L10n.Ux.Breathless.p4])
            .bind(to: tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = "\(element)"
                cell.textLabel?.font = .systemFont(ofSize: 14)
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
                cell.backgroundColor = .clear
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.imageView?.image = UIImage(named: images[row])
                return cell
            }
            .disposed(by: disposeBag)
        
        
        tableView.rx.itemSelected
            .subscribe(onNext: {indexPath in
                if indexPath[1] == 0{
                    print ("0")
                }
                else if indexPath[1] == 1{
                    print ("1")
                }
                else if indexPath[1] == 2{
                    print ("2")
                }
                else if indexPath[1] == 3{
                    print ("3")
                }
                else if indexPath[1] == 4{
                    print ("4")
                }
                else{
                    print ("Invalid Selection")
                }
            })
            .disposed(by: disposeBag)
     }
}

