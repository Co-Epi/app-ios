import UIKit
import RxSwift
import RxCocoa

class AlertsViewController: UIViewController {
    private let viewModel: AlertsViewModel
    private let dataSource: AlertsDataSource = .init()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contactAlerts: UITableView!
    @IBOutlet weak var updateStatusLabel: UILabel!
    @IBOutlet weak var subtextLabel: UILabel!
    @IBOutlet weak var buttonlabel: UIButton!

    private let disposeBag = DisposeBag()

    private let refreshControl = UIRefreshControl()

    init(viewModel: AlertsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)

        title = L10n.Alerts.title
        dataSource.onAcknowledged = { alert in
            viewModel.acknowledge(alert: alert)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "Background_white.png"))

        setupTableView()

        buttonlabel.setTitle(L10n.Alerts.buttonLabel, for: .normal)
        subtextLabel.text = L10n.Alerts.subtitle
        titleLabel.text = L10n.Alerts.header

        ButtonStyles.applyUnselected(to: buttonlabel)
        buttonlabel.addTarget(self, action: #selector(onTouchDown(to:)), for: .touchDown)
        buttonlabel.addTarget(self, action: #selector(onTouchUp), for: .touchUpInside)
        buttonlabel.addTarget(self, action: #selector(onTouchUp(to:)), for: .touchUpOutside)

        viewModel.alertCells
            .drive(contactAlerts.rx.items(dataSource: dataSource))
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
    }

    @objc func onTouchDown(to button: UIButton) {
        ButtonStyles.applySelected(to: button)
    }

    @objc func onTouchUp(to button: UIButton) {
        ButtonStyles.applyUnselected(to: button)
    }

    private func setupTableView() {
        contactAlerts.register(cellClass: AlertCell.self)

        contactAlerts.rowHeight = UITableView.automaticDimension
        contactAlerts.estimatedRowHeight = 20

        contactAlerts.addSubview(refreshControl)
    }

    @IBAction func onWhatAreAlertsPress(_ sender: Any) {
        let viewController = WhatAreAlertsViewController()
        present(viewController, animated: true, completion: nil)
    }
}

class AlertsDataSource: NSObject, RxTableViewDataSourceType {
    private(set) var sections: [AlertViewDataSection] = []
    public var onAcknowledged: ((AlertViewData) -> Void)?

    func tableView(_ tableView: UITableView, observedEvent: RxSwift.Event<[AlertViewDataSection]>) {
        if case let .next(sections) = observedEvent {
            self.sections = sections
            tableView.reloadData()
        }
    }
}

extension AlertsDataSource: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].alerts.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeue(
            cellClass: AlertCell.self,
            forIndexPath: indexPath)
        guard let alertCell = cell as? AlertCell else { return cell }

        let alert: AlertViewData = sections[indexPath.section].alerts[indexPath.row]

        alertCell.setup(alert: alert,
                        onAcknowledged: { [weak self] alert in
                            self?.onAcknowledged?(alert)
                        },
                        onReadDotAnimated: { [weak self] in
                            self?
                                .sections[indexPath.section]
                                .alerts[indexPath.row]
                                .animateUnreadDot = false
        })

        return alertCell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
}

extension AlertsViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int)
        -> UIView? {
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

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int)
        -> CGFloat {
        20
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(
        style: .destructive,
        title: L10n.Alerts.Label
            .archive) { [viewModel, dataSource] (action, view, actionPerformed: (Bool)
            -> Void) in
            viewModel.acknowledge(
                alert: dataSource.sections[indexPath.section].alerts[indexPath.row])
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = dataSource.sections[indexPath.section].alerts[indexPath.row]
        viewModel.onAlertTap(alert: alert)
    }
}
