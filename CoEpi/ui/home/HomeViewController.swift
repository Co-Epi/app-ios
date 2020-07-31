import UIKit
import SafariServices
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel

    @IBOutlet weak var howDataUsedLabel: UIButton!

    @IBOutlet weak var tableView: UITableView!
    private var dataSource = HomeItemsDataSource()

    private let disposeBag = DisposeBag()

    @IBAction func howDataUsedButton(_ sender: Any) {
        if let url = URL(string: "https://www.coepi.org/privacy/") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var buildLabel: UILabel!

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
        self.title = self.viewModel.title
    }

    required init?(coder: NSCoder) {
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

        howDataUsedLabel.setTitle(L10n.Ux.Home.how, for: .normal)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200

        versionLabel.text = viewModel.versionNameString
        buildLabel.text = viewModel.buildString

        tableView.register(cellClass: HomeItemCell.self)

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
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HomeItemCell = tableView.dequeue(
            cellClass: HomeItemCell.self,
            forIndexPath: indexPath)
        cell.setup(viewData: items[indexPath.row])
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        viewModel.onClick(item: dataSource.items[indexPath.row])
    }
}
