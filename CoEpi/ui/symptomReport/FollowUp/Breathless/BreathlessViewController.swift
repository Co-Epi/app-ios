import UIKit
import RxSwift
import RxCocoa

class BreathlessViewController: UIViewController {
    private let viewModel: BreathlessViewModel

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var skipButtonLabel: UIButton!

    private var dataSource = BreathlessDataSource()

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

        viewModel.viewData
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [viewModel, dataSource] indexPath in
                viewModel.onCauseSelected(viewData: dataSource.viewData[indexPath.row])
            })
            .disposed(by: disposeBag)
     }
}

private class BreathlessDataSource: NSObject, RxTableViewDataSourceType {
    private(set) var viewData: [BreathlessItemViewData] = []

    func tableView(
        _ tableView: UITableView,
        observedEvent: RxSwift.Event<[BreathlessItemViewData]>) {
        if case let .next(viewData) = observedEvent {
            self.viewData = viewData
            tableView.reloadData()
        }
    }
}

extension BreathlessDataSource: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewData.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeue(
            cellClass: UITableViewCell.self,
            forIndexPath: indexPath)

        let viewData = self.viewData[indexPath.row]

        cell.textLabel?.text = viewData.text
        cell.textLabel?.font = .systemFont(ofSize: 14)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.imageView?.image = UIImage(named: viewData.imageName)

        return cell
    }
}
