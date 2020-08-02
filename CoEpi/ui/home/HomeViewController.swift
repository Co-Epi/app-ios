import RxCocoa
import RxSwift
import SafariServices
import UIKit

class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel

    @IBOutlet var tableView: UITableView!
    private var dataSource = HomeItemsDataSource()

    private let disposeBag = DisposeBag()

    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var buildLabel: UILabel!

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
        title = self.viewModel.title
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func debugTapped(_: UIButton) {
        viewModel.debugTapped()
    }

    @IBAction func onSettingsTap() {
        viewModel.onSettingsTap()
    }

    @objc func share(sender: UIView) {
        Sharer().share(viewController: self, sourceView: sender)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Background_purple"))

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200

        versionLabel.text = viewModel.versionNameString
        buildLabel.text = viewModel.buildString

        tableView.register(cellClass: HomeItemCell.self)
        tableView.register(cellClass: HomeTitledItemCell.self)

        viewModel.items
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

private class HomeItemsDataSource: NSObject, RxTableViewDataSourceType {
    private(set) var items: [HomeItemViewData] = []

    func tableView(_ tableView: UITableView, observedEvent: RxSwift.Event<[HomeItemViewData]>) {
        if case let .next(items) = observedEvent {
            self.items = items
            tableView.reloadData()
        }
    }
}

extension HomeItemsDataSource: UITableViewDataSource {
    func tableView(
        _: UITableView,
        numberOfRowsInSection _: Int
    ) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let item = items[indexPath.row]

        switch item {
        case let item as HomeTitledItemViewData:
            let cell = tableView.dequeue(cellClass: HomeTitledItemCell.self,
                                         forIndexPath: indexPath)
            cell.setup(viewData: item)
            return cell
        default:
            let cell = tableView.dequeue(cellClass: HomeItemCell.self,
                                         forIndexPath: indexPath)
            cell.setup(viewData: items[indexPath.row])
            return cell
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(
        _: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        viewModel.onClick(item: dataSource.items[indexPath.row])
    }
}
