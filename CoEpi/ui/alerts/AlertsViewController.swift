import RxCocoa
import RxSwift
import UIKit

class AlertsViewController: UIViewController, ErrorDisplayer {
    private let viewModel: AlertsViewModel

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contactAlerts: UITableView!
    @IBOutlet var updateStatusLabel: UILabel!
    @IBOutlet var subtextLabel: UILabel!

    private let disposeBag = DisposeBag()

    private let refreshControl = UIRefreshControl()

    private lazy var dataSource = makeDataSource(
        tableView: contactAlerts, onAcknowledged: { [weak self] viewData in
            self?.viewModel.acknowledge(alert: viewData)
        }
    )

    // Items for which the dot animation ran already, to not run it again
    private var dotAnimatedCells = Set<AlertViewData>()

    init(viewModel: AlertsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)

        title = L10n.Alerts.title
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Background_white.png"))

        setupTableView()

        subtextLabel.text = L10n.Alerts.subtitle
        titleLabel.text = L10n.Alerts.header

        viewModel.alertCells
            .asObservable().subscribe(onNext: { [dataSource] in
                dataSource.applySnapshot(sections: $0.sections,
                                         animatingDifferences: $0.animate)
            })
            .disposed(by: disposeBag)

        viewModel.updateStatusText
            .drive(updateStatusLabel.rx.text)
            .disposed(by: disposeBag)

        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [viewModel, refreshControl] in
                viewModel.updateReports()
                // Hide refresh control immediately. Progress status is shown in label.
                refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
    
        viewModel.notification
            .drive(rx.notification)
            .disposed(by: disposeBag)
    }

    private func setupTableView() {
        contactAlerts.register(cellClass: AlertCell.self)

        contactAlerts.rowHeight = UITableView.automaticDimension
        contactAlerts.estimatedRowHeight = 20

        contactAlerts.addSubview(refreshControl)
    }

    func makeDataSource(
        tableView: UITableView,
        onAcknowledged: ((AlertViewData) -> Void)?
    ) -> AlertsDataSource {
        AlertsDataSource(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, alert -> AlertCell? in
                let cell: AlertCell = tableView.dequeue(
                    cellClass: AlertCell.self,
                    forIndexPath: indexPath
                )
                guard let self = self else { return cell }

                cell.setup(alert: alert,
                           animateRedDot: !self.dotAnimatedCells.contains(alert),
                           onAcknowledged: { alert in
                               onAcknowledged?(alert)
                           },
                           onReadDotAnimated: { [weak self] in
                               self?.dotAnimatedCells.insert(alert)
                           })
                return cell
            }
        )
    }
}

class AlertsDataSource: UITableViewDiffableDataSource<AlertViewDataSection, AlertViewData> {
    var sections: [AlertViewDataSection] = []

    func applySnapshot(sections: [AlertViewDataSection], animatingDifferences: Bool = true) {
        self.sections = sections

        var snapshot = NSDiffableDataSourceSnapshot<AlertViewDataSection, AlertViewData>()
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.alerts, toSection: section)
        }
        apply(snapshot, animatingDifferences: animatingDifferences)
    }

    override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        true
    }
}

extension AlertsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        let label = UILabel(frame: CGRect(x: 24, y: 5, width: 0, height: 0))
        label.backgroundColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = .coEpiPurple
        label.text = dataSource.sections[section].header
        label.sizeToFit()
        view.addSubview(label)
        view.backgroundColor = .clear
        return view
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        20
    }

    func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(
            style: .destructive,
            title: L10n.Alerts.Label
                .archive
        ) { [viewModel, dataSource] (_, _, completionHandler: (Bool) -> Void) in
            viewModel.acknowledge(
                alert: dataSource.sections[indexPath.section].alerts[indexPath.row])
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = dataSource.sections[indexPath.section].alerts[indexPath.row]
        viewModel.onAlertTap(alert: alert)
    }
}
