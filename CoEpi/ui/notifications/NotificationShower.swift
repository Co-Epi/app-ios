import UIKit

protocol NotificationShower {
    func showNotification(data: NotificationData)
    func clearScheduledNotifications()
    func listScheduledNotifications()
}

class NotificationShowerImpl: NotificationShower {
    func listScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { pendingNotifications in
            if 0 == pendingNotifications.count {
                log.d("There are no pending notification requests", tags: .ui)
            } else {
                log.d("Pending local notification requests:", tags: .ui)
                for notif in pendingNotifications {
                    log.d(notif.description, tags: .ui)
                }
            }
        })
    }
    
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
        let content = UNMutableNotificationContent()
        content.title = data.title
        content.body = data.body
        content.sound = canPlaySound ? .default : nil
        switch data.id {
        case .alerts:
            log.d("Showing notification in 1 sec")
            let request = UNNotificationRequest(
                identifier: data.id.rawValue,
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                           repeats: false)
            )
            UNUserNotificationCenter.current().add(request)
        case .reminders:
            let hours = 18
            let mins = 0
            log.d("Scheduling reminder notification for \(hours) : \(mins)", tags: .ui)
            let timeAtWhichToTriggerNotification: DateComponents = DateComponents(hour: hours, minute: mins)
            let request = UNNotificationRequest(
                identifier: data.id.rawValue,
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: timeAtWhichToTriggerNotification, repeats: true)
            )
            log.d("Request: \(request)", tags: .ui)
            UNUserNotificationCenter.current().add(request) { (error: Error?) in
                if let e = error {
                    log.e(e.localizedDescription, tags:.ui)
                }
            }
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
