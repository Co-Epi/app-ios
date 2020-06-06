import Foundation
import os.log

protocol MatchingReportsHandler {
    func handleMatchingReports(reports: [ReceivedCenReport])
}

class MatchingReportsHandlerImpl: MatchingReportsHandler {
    private let reportsDao: CENReportDao
    private let notificationShower: NotificationShower
    private let appBadgeUpdater: AppBadgeUpdater

    init(reportsDao: CENReportDao, notificationShower: NotificationShower, appBadgeUpdater: AppBadgeUpdater) {
        self.reportsDao = reportsDao
        self.notificationShower = notificationShower
        self.appBadgeUpdater = appBadgeUpdater
    }

    func handleMatchingReports(reports: [ReceivedCenReport]) {
        let insertedCount = reports.map {
            reportsDao.insert(report: $0)
        }.filter { $0 }.count

        if insertedCount > 0 {
            notifiyNewAlerts(count: insertedCount)
        }

        os_log("Alerts update task finished. Saved new reports: %{public}d", log: servicesLog, type: .debug, insertedCount)
    }

    private func notifiyNewAlerts(count: Int) {
        notificationShower.showNotification(data: NotificationData(
            id: .alerts,
            title: "New Contact Alerts",
            body: "New contact alerts have been detected. Tap for details.")
        )
        appBadgeUpdater.updateAppBadge(number: count)
    }
}
