import Foundation
import RxSwift
import SwiftUI

struct AlertDetailsViewModelParams {
    let alert: Alert
    let linkedAlerts: [Alert]
}

class AlertDetailsViewModel: ObservableObject {
    private let alertRepo: AlertRepo
    private let nav: RootNav
    private var email: Email

    @Published var viewData: AlertDetailsViewData = .empty()

    let linkedAlertsViewData: [LinkedAlertViewData]

    @Published var showingActionSheet = false

    private let disposeBag = DisposeBag()

    init(pars: AlertDetailsViewModelParams, alertRepo: AlertRepo, nav: RootNav, email: Email,
         unitsFormatter: UnitsFormatter)
    {
        self.alertRepo = alertRepo
        self.nav = nav
        self.email = email

        linkedAlertsViewData = pars.linkedAlerts
            .enumerated()
            .map { index, alert in alert.toLinkedAlertViewData(
                image: .from(alertIndex: index, alertsCount: pars.linkedAlerts.count),
                bottomLine: index < pars.linkedAlerts.count - 1
            ) }

        unitsFormatter.formatter.map {
            pars.alert.toViewData(measurementFormatter: $0)
        }.subscribe(onNext: { [weak self] in
            self?.viewData = $0
        }).disposed(by: disposeBag)
    }

    func delete() {
        switch alertRepo.removeAlert(alert: viewData.alert) {
        case .success:
            log.i("Alert: \(viewData.alert.id) was removed.")
            nav.navigate(command: .back)
        case let .failure(e):
            log.e("Alert: \(viewData.alert.id) couldn't be removed: \(e)")
        }
    }

    func showActionSheet() {
        showingActionSheet = true
    }

    func reportProblemTapped() {
        email.openEmail(address: "TODO@TODO.TODO", subject: "TODO")
    }
}

private extension Alert {
    func toViewData(measurementFormatter: MeasurementFormatter) -> AlertDetailsViewData {
        guard
            let formattedAvgDistance = formatterdAvgDistance(
                measurementFormatter: measurementFormatter),
            let formattedMinDistance = formatterdMinDistance(
                measurementFormatter: measurementFormatter)
        else { fatalError("Format error: \(self)") }

        return AlertDetailsViewData(
            title: formattedStartDate(),
            contactStart: formattedContactStart(),
            contactDuration: formattedContactDuration(),
            avgDistance: formattedAvgDistance,
            minDistance: formattedMinDistance, // Temporary, for testing
            reportTime: formatReportTime(date: reportTime.toDate()),
            symptoms: formattedSymptoms(),
            alert: self
        )
    }

    func toLinkedAlertViewData(image: LinkedAlertViewDataConnectionImage,
                               bottomLine: Bool) -> LinkedAlertViewData
    {
        LinkedAlertViewData(
            date: formattedStartDate(),
            contactStart: formattedContactStart(),
            contactDuration: formattedContactDuration(),
            symptoms: formattedSymptoms(),
            alert: self,
            image: image,
            bottomLine: bottomLine
        )
    }

    private func formattedStartDate() -> String {
        start.toDate().formatMonthOrdinalDay()
    }

    private func formattedContactStart() -> String {
        DateFormatters.hoursMins.string(from: start.toDate())
    }

    private func formattedContactDuration() -> String {
        durationForUI.toLocalizedString()
    }

    private func formattedSymptoms() -> String {
        symptomUIStrings().joined(separator: "\n")
    }

    private func formatterdAvgDistance(measurementFormatter: MeasurementFormatter) -> String? {
        let formatted = measurementFormatter.string(from: minDistance)
        return L10n.Alerts.Details.Distance.avg(formatted)
    }

    private func formatterdMinDistance(measurementFormatter: MeasurementFormatter) -> String? {
        let formatted = measurementFormatter.string(from: minDistance)
        return "[DEBUG] Min distance: \(formatted)" // Temporary, for testing
    }

    private func formattedDistance(unit: UnitLength, distance: Measurement<UnitLength>) -> String? {
        NumberFormatters.oneDecimal.string(
            from: Float(distance.converted(to: unit).value))
    }

    private func formatReportTime(date: Date) -> String {
        let monthDay = DateFormatters.monthDay.string(from: date)
        let time = DateFormatters.hoursMins.string(from: date)

        return L10n.Alerts.Details.Label.reportedOn(monthDay, time)
    }
}

extension ExposureDurationForUI {
    func toLocalizedString() -> String {
        switch self {
        case let .hoursMinutes(hours, mins):
            return L10n.Alerts.Details.Duration.hoursMinutes(hours, mins)
        case let .minutes(mins):
            return L10n.Alerts.Details.Duration.minutes(mins)
        case let .seconds(secs):
            return L10n.Alerts.Details.Duration.seconds(secs)
        }
    }
}
