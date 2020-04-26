import Foundation
import UserNotifications
import os.log
import UIKit

protocol AppBadgeUpdater {
    func updateAppBadge(number: Int)
}

class AppBadgeUpdaterImpl: AppBadgeUpdater {

    func updateAppBadge(number: Int) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            self?.updateAppBadge(number: number, settings: settings)
        }
    }

    private func updateAppBadge(number: Int, settings: UNNotificationSettings) {
        guard
            settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional,
            settings.badgeSetting == .enabled
        else { return }

        DispatchQueue.main.async {
            os_log("Updating app badge: %{public}@", log: servicesLog, type: .debug, "\(number)")
            UIApplication.shared.applicationIconBadgeNumber = number
        }
    }
}
