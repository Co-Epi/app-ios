import UIKit
import RxSwift
import RxCocoa

class AlertsViewController: UIViewController {
    private let viewModel: AlertsViewModel
    private let dataSource: AlertsDataSource = .init()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contactAlerts: UITableView!

    private let disposeBag = DisposeBag()

    init(viewModel: AlertsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
        
        title = "Alerts"
        dataSource.onAcknowledged = { (alert) in
            viewModel.acknowledge(alert: alert)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        setupTableView()

        viewModel.title
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.alerts
            .drive(contactAlerts.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    private func setupTableView() {
        contactAlerts.rowHeight = UITableView.automaticDimension
        contactAlerts.estimatedRowHeight = 120
        contactAlerts.register(cellClass: AlertCell.self)
    }
}

class AlertsDataSource: NSObject, RxTableViewDataSourceType {
    private var alerts: [Alert] = []
    public var onAcknowledged: ((Alert) -> ())?

    func tableView(_ tableView: UITableView, observedEvent: RxSwift.Event<[Alert]>) {
        if case let .next(alerts) = observedEvent {
            self.alerts = alerts
            tableView.reloadData()
        }
    }
}

extension AlertsDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        alerts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeue(cellClass: AlertCell.self, forIndexPath: indexPath)
        guard let alertCell = cell as? AlertCell else { return cell }

        let alert: Alert = alerts[indexPath.row]
        alertCell.setAlert(alert: alert)
        alertCell.onAcknowledged = onAcknowledged

        return alertCell
    }
}
