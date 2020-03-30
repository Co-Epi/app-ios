//
//  AlertsViewController.swift
//  CoEpi
//
//  Created by Dusko Ojdanic on 3/26/20.
//  Copyright © 2020 org.coepi. MIT licensed: see LICENSE file.
//

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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        contactAlerts.register(cellClass: AlertCell.self)

        viewModel.title
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.alerts
            .drive(contactAlerts.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

class AlertsDataSource: NSObject, RxTableViewDataSourceType {
    private var alerts: [Alert] = []
    
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

        alertCell.onAcknowledged = { [weak self] (alert) in
            // TODO: what happens in the UI when an alert is acknowledged?
            // TODO: pipe to VM
            print("Acknowledged \(alert)")
        }

        return alertCell
    }
}
