import UIKit

protocol NotificationShower {
    func showNotification(data: NotificationData)
    func clearScheduledNotifications()
}

class NotificationShowerImpl: NotificationShower {
    func clearScheduledNotifications() {
        log.d("Removing pending local notification requests...", tags: .ui)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func showNotification(data: NotificationData) {
        UNUserNotificationCenter
            .current()
            .getNotificationSettings { [weak self] settings in
                self?.showNotification(data: data, settings: settings)
            }
    }

    private func showNotification(
        data: NotificationData,
        settings: UNNotificationSettings
    ) {
        guard settings.authorizationStatus == .authorized ||
            settings.authorizationStatus == .provisional
        else {
            return
        }

        if settings.alertSetting == .enabled {
            showNotification(data: data, canPlaySound: settings.soundSetting == .enabled)
        }
        // Note: If alert isn't enabled, we don't play sound either
    }

    private func showNotification(data: NotificationData, canPlaySound: Bool) {
        log.d("Showing notification")

        let content = UNMutableNotificationContent()
        content.title = data.title
        content.body = data.body
        content.sound = canPlaySound ? .default : nil
        switch data.id {
        case .alerts:
            let request = UNNotificationRequest(
                identifier: data.id.rawValue,
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                           repeats: false)
            )
            UNUserNotificationCenter.current().add(request)
        case .reminders:
            log.d("Scheduling reminder for 18", tags: .ui)
            let timeAtWhichToTriggerNotification: DateComponents = DateComponents(hour: 18)
            let request = UNNotificationRequest(
                identifier: data.id.rawValue,
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: timeAtWhichToTriggerNotification, repeats: true)
            )
            UNUserNotificationCenter.current().add(request)
        }
    }
}

struct NotificationData {
    let id: NotificationId
    let title: String
    let body: String
}

enum NotificationId: String {
    case alerts
    case reminders
}
