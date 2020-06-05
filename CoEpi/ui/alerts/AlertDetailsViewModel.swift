import Foundation

class AlertDetailsViewModel {
    let viewData: AlertDetailsViewData

    init(alert: Alert) {
        viewData = alert.toViewData()
    }
}

private extension Alert {

    func symptomListString() -> String {
        [
            coughSeverity.toSymptomUIString(),
            breathlessnessUIString(),
            feverSeverity.toSymptomUIString()
        ]
            .compactMap { $0 }
            .map { "• \($0)" }
            .joined(separator: "\n")
    }

    func toViewData() -> AlertDetailsViewData {
        AlertDetailsViewData(
            title: contactTime.toDate().formatMonthOrdinalDay(),
            contactTime: DateFormatters.hoursMins.string(from: contactTime.toDate()),
            reportTime: formatReportTime(date: reportTime.toDate()),
            symptoms: symptomListString(),
            alert: self
        )
    }

    func formatReportTime(date: Date) -> String {
        let monthDay = DateFormatters.monthDay.string(from: date)

        // For the weirdest reason, this formatter returns an optional, though it has exactly the same interface as
        // the month day formatter. Seems to be a compiler bug.
        // TODO revisit, maybe in future Xcode versions.
        let time = DateFormatters.hoursMins.string(for: date)!

        return L10n.Alerts.Details.Label.reportedOn(monthDay, time)
    }
}
