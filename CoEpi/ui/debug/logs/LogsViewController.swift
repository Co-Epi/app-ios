import UIKit
import RxSwift
import RxCocoa

class LogsViewController: UIViewController, ErrorDisplayer {
    private let viewModel: LogsViewModel

    @IBOutlet weak var tableView: UITableView!

    private let disposeBag = DisposeBag()

    private var dataSource = LogsTableViewDataSource()

    init(viewModel: LogsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
        self.view.addGestureRecognizer(longPressRecognizer)
    }

    @objc func onLongPress(sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            viewModel.onLongPress()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        setupTableView()

        viewModel.logs
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        viewModel.notification
            .drive(rx.notification)
            .disposed(by: disposeBag)
    }

    private func setupTableView() {
        tableView.register(cellClass: UITableViewCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 20
    }
}

private class LogsTableViewDataSource: NSObject, RxTableViewDataSourceType {
    private var debugEntries: [LogMessageViewData] = []

    func tableView(_ tableView: UITableView, observedEvent: RxSwift.Event<[LogMessageViewData]>) {
        if case let .next(debugEntries) = observedEvent {
            self.debugEntries = debugEntries
            tableView.reloadData()
        }
    }
}

extension LogsTableViewDataSource: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        debugEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeue(cellClass: UITableViewCell.self, forIndexPath: indexPath)

        cell.selectionStyle = .none

        let label = cell.textLabel
        label?.font = .systemFont(ofSize: 14)

        let logMessage = debugEntries[indexPath.row]

        label?.numberOfLines = 0

        // For now only concatenated
        label?.text = logMessage.time + " " + logMessage.text

        label?.textColor = logMessage.textColor

        return cell
    }
}
