import UIKit

protocol NotificationShower {

    func scheduleNotification(data: NotificationData)
    func clearScheduledNotifications()
    func listScheduledNotifications()
    func scheduleReminderNotificationsForNext(days: Int)
    func cancelReminderNotificationForTheDay()
}

class NotificationShowerImpl: NotificationShower {
    private var kvStore: ObservableKeyValueStore
    
    init(kvStore: ObservableKeyValueStore) {
        self.kvStore = kvStore
    }

    func cancelReminderNotificationForTheDay() {
        cancelReminderNotificationFor(date: Date())
    }
    
    private func cancelReminderNotificationFor(date: Date) {
        let notifIdentifier = getIdentifierFromDate(date: Date())
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { pendingNotifications in
            var cancellationIdentifiers: [String] = []
            for notif in pendingNotifications where notifIdentifier == notif.identifier {
                cancellationIdentifiers.append(notifIdentifier)
            }
            log.w("Canceling notification with identifiers: \(cancellationIdentifiers)", tags: .ui)
            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: cancellationIdentifiers)
        })
    }
    
    
    private func getIdentifierFromDate(date: Date) -> String {
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let notifIdentifier = String(format: "%04d%02d%02d",
                                 arguments: [dateComponents.year!, dateComponents.month!, dateComponents.day!])
//        log.d("notifIdentifier: \(notifIdentifier)")
        return notifIdentifier
    }
    
    func scheduleReminderNotificationsForNext(days: Int) {
        let calendar: Calendar = Calendar.current

        var date = Date()
        var notifIdentifier = ""
        var identifiersToSchedule: Set<String> = Set<String>()

        for _ in 1...days {
            date = calendar.date(byAdding: .day, value: 1, to: date)!
            notifIdentifier = getIdentifierFromDate(date: date)
            identifiersToSchedule.insert(notifIdentifier)
        }
        log.d("All identifiersToSchedule: \(identifiersToSchedule)")
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { pendingNotifications in
            if 0 == pendingNotifications.count {
                log.d("There are no pending notification requests", tags: .ui)
            } else {
                log.d("Pending local notification requests count: \(pendingNotifications.count)", tags: .ui)
                for notif in pendingNotifications {
                    log.d(notif.description, tags: .ui)
                    if identifiersToSchedule.contains(notif.identifier) {
                        identifiersToSchedule.remove(notif.identifier)
                    }
                }
            }
            log.d("Remaining identifiersToSchedule: \(identifiersToSchedule)")
            for stringIdentifier in identifiersToSchedule {
                self.scheduleNotification(data:
                    NotificationData(
                        id: .reminders(stringIdentifier),
                        title: L10n.Reminder.Notification.title,
                        body: L10n.Reminder.Notification.body,
                        //TODO: can be removed? (hours, minutes)
                        hours: nil,
                        minutes: nil
                    )
                )
            }
        })
    }

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

    func scheduleNotification(data: NotificationData) {
        UNUserNotificationCenter
            .current()
            .getNotificationSettings { [weak self] settings in
                if true == self?.isAuthorizedForShowing(data: data, settings: settings) {
                    self?.scheduleNotificationForShowing(data: data, canPlaySound: settings.soundSetting == .enabled)
                }
            }
    }

    private func isAuthorizedForShowing(
        data: NotificationData,
        settings: UNNotificationSettings
    ) -> Bool {
        guard settings.authorizationStatus == .authorized ||
            settings.authorizationStatus == .provisional
        else {
            return false
        }

        if settings.alertSetting == .enabled {
            return true
        }
        // Note: If alert isn't enabled, we don't play sound either
        return false
    }

    private func scheduleNotificationForShowing(data: NotificationData, canPlaySound: Bool) {

        let content = UNMutableNotificationContent()
        content.title = data.title
        content.body = data.body
        content.sound = canPlaySound ? .default : nil
        switch data.id {
        case .alerts:
            log.d("Showing notification in 1 sec")
            let request = UNNotificationRequest(
                identifier: "alerts",
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                           repeats: false)
            )
            UNUserNotificationCenter.current().add(request)

        case .reminders (let id):
            //id="20200926"
            let year = Int(id.prefix(4))
            let monthDay = id.suffix(4)
            let month = Int(monthDay.prefix(2))
            let day = Int(monthDay.suffix(2))
            
            var hours = 18
            if let h = Int(kvStore.getReminderHours()) {
                hours = h
            }
            var mins = 0
            if let m = Int(kvStore.getReminderMinutes()) {
                mins = m
            }
            log.d("Scheduling reminder notification for \(String(describing: hours)) : \(String(describing: mins))",
                  tags: .ui)
            let timeAtWhichToTriggerNotification: DateComponents = DateComponents(year: year, month: month, day: day, hour: hours, minute: mins)
            let request = UNNotificationRequest(
                identifier: id,
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: timeAtWhichToTriggerNotification, repeats: false)
            )
            log.d("Request: \(request)", tags: .ui)
            UNUserNotificationCenter.current().add(request) { (error: Error?) in
                if let e = error {
                    log.e(e.localizedDescription, tags: .ui)
                }
            }
        }
    }
}

struct NotificationData {
    let id: NotificationId
    let title: String
    let body: String
    let hours: String?
    let minutes: String?
}

enum NotificationId {
    case alerts
    case reminders(String)

}
