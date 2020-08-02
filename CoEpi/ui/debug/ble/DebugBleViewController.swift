import RxCocoa
import RxSwift
import UIKit

class DebugBleViewController: UIViewController {
    private let viewModel: DebugBleViewModel

    @IBOutlet var tableView: UITableView!

    private let disposeBag = DisposeBag()

    private var dataSource = DebugListDataSource()

    init(viewModel: DebugBleViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        tableView.register(cellClass: UITableViewCell.self)

        viewModel.debugEntries
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

private class DebugListDataSource: NSObject, RxTableViewDataSourceType {
    private var debugEntries: [DebugBleEntryViewData] = []

    func tableView(
        _ tableView: UITableView,
        observedEvent: RxSwift.Event<[DebugBleEntryViewData]>
    ) {
        if case let .next(debugEntries) = observedEvent {
            self.debugEntries = debugEntries
            tableView.reloadData()
        }
    }
}

extension DebugListDataSource: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        debugEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeue(
            cellClass: UITableViewCell.self,
            forIndexPath: indexPath
        )
        let label = cell.textLabel
        label?.font = .systemFont(ofSize: 14)

        switch debugEntries[indexPath.row] {
        case let .header(text):
            label?.text = text
            cell.backgroundColor = .lightGray
        case let .item(text):
            label?.text = text
            cell.backgroundColor = .clear
        }
        return cell
    }
}
