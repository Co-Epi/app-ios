import Foundation
import SwiftUI

class AlertDetailsViewModel: ObservableObject {
    private let alertRepo: AlertRepo
    private let nav: RootNav
    private var email: Email

    let viewData: AlertDetailsViewData
    let linkedAlertsViewData: [LinkedAlertViewData]

    @Published var showingActionSheet = false

    init(alert: Alert, alertRepo: AlertRepo, nav: RootNav, email: Email) {
        self.alertRepo = alertRepo
        self.nav = nav
        self.email = email

        viewData = alert.toViewData()

        let linkedAlerts = alertRepo
            .linkedAlerts(alert: alert)
            .expect("Couldn't retrieve linked alerts")
        linkedAlertsViewData = linkedAlerts
            .enumerated()
            .map { index, alert in alert.toLinkedAlertViewData(
                image: .from(alertIndex: index, alertsCount: linkedAlerts.count),
                bottomLine: index < linkedAlerts.count - 1
            )}
    }

    func delete() {
        switch alertRepo.removeAlert(alert: viewData.alert) {
        case .success:
            log.i("Alert: \(viewData.alert.id) was removed.")
            nav.navigate(command: .back)
        case .failure(let e):
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

    func toViewData() -> AlertDetailsViewData {
        let distanceUnit = UnitLength.feet
        guard
            let formattedAvgDistance = formatterdAvgDistance(unit: distanceUnit),
            let formattedMinDistance = formatterdMinDistance(unit: distanceUnit)
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
                               bottomLine: Bool) -> LinkedAlertViewData {
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

    private func formatterdAvgDistance(unit: UnitLength) -> String? {
        guard
            let formatted = formattedDistance(unit: unit, distance: minDistance)
        else { fatalError("Couldn't format distance: \(avgDistance)") }

        return L10n.Alerts.Details.Distance.avg(formatted,
                                                L10n.Alerts.Details.Distance.Unit.feet)
    }

    private func formatterdMinDistance(unit: UnitLength) -> String? {
        guard
            let formatted = formattedDistance(unit: unit, distance: minDistance)
        else { fatalError("Couldn't format distance: \(avgDistance)") }

        return "[DEBUG] Min distance: \(formatted) " +
            "\(L10n.Alerts.Details.Distance.Unit.feet)" // Temporary, for testing
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
        case .hoursMinutes(let hours, let mins):
            return L10n.Alerts.Details.Duration.hoursMinutes(hours, mins)
        case .minutes(let mins):
            return L10n.Alerts.Details.Duration.minutes(mins)
        case .seconds(let secs):
            return L10n.Alerts.Details.Duration.seconds(secs)
        }
    }
}
