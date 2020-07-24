import Foundation
import SwiftUI

class AlertDetailsViewModel: ObservableObject {
    let viewData: AlertDetailsViewData
    
    init(alert: Alert) {
        viewData = alert.toViewData()
    }
}

private extension Alert {
    
    func toViewData() -> AlertDetailsViewData {
        let distanceUnit = UnitLength.feet
        
        guard
            let formattedAvgDistance = NumberFormatters.oneDecimal.string(
                from: Float(avgDistance.converted(to: distanceUnit).value)),
            let formattedMinDistance = NumberFormatters.oneDecimal.string(
                from: Float(minDistance.converted(to: distanceUnit).value))
            else { fatalError("Couldn't format distance: \(avgDistance)") }
        
        return AlertDetailsViewData(
            title: start.toDate().formatMonthOrdinalDay(),
            contactStart: DateFormatters.hoursMins.string(from: start.toDate()),
            contactDuration: durationForUI.toLocalizedString(),
            avgDistance: L10n.Alerts.Details.Distance.avg(formattedAvgDistance,
                                                          L10n.Alerts.Details.Distance.Unit.feet),
            minDistance: "[DEBUG] Min distance: \(formattedMinDistance) " +
            "\(L10n.Alerts.Details.Distance.Unit.feet)", // Temporary, for testing
            reportTime: formatReportTime(date: reportTime.toDate()),
            symptoms: symptomUIStrings().joined(separator: "\n"),
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
