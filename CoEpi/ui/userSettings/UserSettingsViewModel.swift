import Foundation
import RxSwift

class UserSettingsViewModel: ObservableObject {
    private let kvStore: ObservableKeyValueStore

    @Published var settingsViewData: [IdentifiableUserSettingViewData] = []

    private let disposeBag = DisposeBag()

    private let email: Email

    init(kvStore: ObservableKeyValueStore, alertFilterSettings: AlertFilterSettings,
         envInfos: EnvInfos, email: Email, unitsProvider: UnitsProvider)
    {
        self.kvStore = kvStore
        self.email = email

        Observable.combineLatest(kvStore.filterAlertsWithSymptoms,
                                 kvStore.filterAlertsWithLongDuration,
                                 kvStore.filterAlertsWithShortDistance,
                                 unitsProvider.formatter)
            .map { filterAlertsWithSymptoms,
                   filterAlertsWithLongDuration,
                   filterAlertsWithShortDistance,
                   measurementFormatter in

                buildSettings(filterAlertsWithSymptoms: filterAlertsWithSymptoms,
                              filterAlertsWithLongDuration: filterAlertsWithLongDuration,
                              filterAlertsWithShortDistance: filterAlertsWithShortDistance,
                              alertFilterSettings: alertFilterSettings,
                              appVersionString: "\(envInfos.appVersionName)(\(envInfos.appVersionCode))",
                              measurementFormatter: measurementFormatter)
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
        case .filterAlertsWithShortDistance:
            kvStore.setFilterAlertsWithShortDistance(value: value)
        case .filterAlertsWithLongDuration:
            kvStore.setFilterAlertsWithLongDuration(value: value)
        }
    }

    func onAction(id: UserSettingActionId) {
        switch id {
        case .reportProblem: email.openEmail(address: "TODO@TODO.TODO", subject: "TODO")
        }
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
    case filterAlertsWithShortDistance
}

enum UserSettingActionId {
    case reportProblem
}

private func buildSettings(
    filterAlertsWithSymptoms: Bool,
    filterAlertsWithLongDuration: Bool,
    filterAlertsWithShortDistance: Bool,
    alertFilterSettings: AlertFilterSettings,
    appVersionString: String,
    measurementFormatter: MeasurementFormatter
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
        UserSettingViewData.toggle(text: L10n.Settings.Item.distanceShorterThan(
            measurementFormatter.string(
                from: alertFilterSettings.distanceShorterThan)),
        value: filterAlertsWithShortDistance,
        id: .filterAlertsWithShortDistance,
        hasBottomLine: false),

        UserSettingViewData.link(text: L10n.Settings.Item.privacyStatement,
                                 url: URL(string: "https://www.coepi.org/privacy/")!),

        UserSettingViewData.textAction(text: L10n.Settings.Item.reportProblem,
                                       id: .reportProblem),

        UserSettingViewData.text(L10n.Settings.Item.version(appVersionString)),

        // Note: index as id assumes hardcoded settings list, as above
    ].enumerated().map { index, data in IdentifiableUserSettingViewData(id: index, data: data) }
}
