import Foundation
import RxSwift

class UserSettingsViewModel: ObservableObject {
    private let kvStore: ObservableKeyValueStore

    @Published var settingsViewData: [IdentifiableUserSettingViewData] = []

    private let disposeBag = DisposeBag()

    private let email: Email
    
    private let notificationShower: NotificationShower

    init(kvStore: ObservableKeyValueStore, alertFilterSettings: AlertFilterSettings,
         envInfos: EnvInfos, email: Email, unitsProvider: UnitsProvider, lengthFormatter: LengthFormatter,
         notificationShower: NotificationShower) {
        self.kvStore = kvStore
        self.email = email
        self.notificationShower = notificationShower

        Observable.combineLatest(kvStore.filterAlertsWithSymptoms,
                                 kvStore.filterAlertsWithLongDuration,
                                 kvStore.reminderNotificationsEnabled)
            .map { filterAlertsWithSymptoms, filterAlertsWithLongDuration, reminderNotificationsEnabled in
                buildSettings(filterAlertsWithSymptoms: filterAlertsWithSymptoms,
                              filterAlertsWithLongDuration: filterAlertsWithLongDuration,
                              reminderNotificationsEnabled: reminderNotificationsEnabled,

                              alertFilterSettings: alertFilterSettings,
                              appVersionString: "\(envInfos.appVersionName)(\(envInfos.appVersionCode))",
                              lengthFormatter: lengthFormatter)
            }
            .subscribe(onNext: { [weak self] viewData in
                self?.settingsViewData = viewData
            })
            .disposed(by: disposeBag)

    }

    func onToggle(id: UserSettingToggleId, value: Bool) {
        switch id {
        case .filterAlertsWithSymptoms:
            // The text says "show all reports" -> negate for filter
            kvStore.setFilterAlertsWithSymptoms(value: !value)
        case .reminderNotificationsEnabled:
            kvStore.setReminderNotificationsEnabled(value: value)
            log.d("Toggling reminder", tags: .ui)
            if value {
                notificationShower.scheduleReminderNotificationsForNext(days: 14)
            } else {
              //clear scheduled reminder notifiations
                notificationShower.clearScheduledNotifications()
            }
        case .filterAlertsWithLongDuration:
            kvStore.setFilterAlertsWithLongDuration(value: value)
        }
//        sleep(1)
//        notificationShower.listScheduledNotifications()
    }

    func onAction(id: UserSettingActionId) {
        switch id {
        case .reportProblem: email.openEmail(address: "CoEpi@OpenAPS.org", subject: "Problem")
        }
    }

    func onReminderSave(hours: String, minutes: String) {
        kvStore.setReminderHours(value: hours)
        kvStore.setReminderMinutes(value: minutes)
    }
}

struct IdentifiableUserSettingViewData: Identifiable {
    let id: Int
    let data: UserSettingViewData
}

enum UserSettingViewData {
    case sectionHeader(title: String, description: String)
    case toggle(text: String, value: Bool, id: UserSettingToggleId, hasBottomLine: Bool)
    case link(text: String, url: URL)
    case textAction(text: String, id: UserSettingActionId)
    case text(String)
}

enum UserSettingToggleId {
    case filterAlertsWithSymptoms
    case filterAlertsWithLongDuration
    case reminderNotificationsEnabled
}

enum UserSettingActionId {
    case reportProblem
}

private func buildSettings(
    filterAlertsWithSymptoms: Bool,
    filterAlertsWithLongDuration: Bool,
    reminderNotificationsEnabled: Bool,
    alertFilterSettings: AlertFilterSettings,
    appVersionString: String,
    lengthFormatter: LengthFormatter
) -> [IdentifiableUserSettingViewData] {
    [
        UserSettingViewData.sectionHeader(
            title: L10n.Settings.Header.Alerts.title,
            description: L10n.Settings.Header.Alerts.descr
        ),
        UserSettingViewData.toggle(
            text: L10n.Settings.Item.allReports,
            value: !filterAlertsWithSymptoms,
            id: .filterAlertsWithSymptoms,
            hasBottomLine: true
        ),
        UserSettingViewData.toggle(
            text: L10n.Settings.Item.durationLongerThanMins(
                Int(alertFilterSettings.durationSecondsLargerThan / 60)),
            value: filterAlertsWithLongDuration,
            id: .filterAlertsWithLongDuration,
            hasBottomLine: true
        ),
        UserSettingViewData.toggle(text: L10n.Settings.Item.reminderNotificationsEnabled,
        value: reminderNotificationsEnabled,
        id: .reminderNotificationsEnabled,
        hasBottomLine: false),

        UserSettingViewData.link(text: L10n.Settings.Item.privacyStatement,
                                 url: URL(string: "https://www.coepi.org/privacy/")!),

        UserSettingViewData.textAction(text: L10n.Settings.Item.reportProblem,
                                       id: .reportProblem),

        UserSettingViewData.text(L10n.Settings.Item.version(appVersionString)),

        // Note: index as id assumes hardcoded settings list, as above
    ].enumerated().map { index, data in IdentifiableUserSettingViewData(id: index, data: data) }
}
