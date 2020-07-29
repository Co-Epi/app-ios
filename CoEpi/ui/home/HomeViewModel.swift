import RxSwift
import RxCocoa

enum HomeItemId {
    case reportSymptoms, alerts
}

struct HomeItemNotification {
    let text: String
}

struct HomeItemViewData {
    let id: HomeItemId
    let title: String
    let descr: String
    var notification: HomeItemNotification?
}

class HomeViewModel {
    private let rootNav: RootNav
    private let alertRepo: AlertRepo
    private let envInfos: EnvInfos

    let title = L10n.Ux.Home.title

    private let itemSelectTrigger = PublishRelay<HomeItemViewData>()

    private static let items = [
        HomeItemViewData(
            id: .reportSymptoms,
            title: L10n.Ux.Home.report1,
            descr: L10n.Ux.Home.report2
        ),
        HomeItemViewData(
            id: .alerts,
            title: L10n.Ux.Home.alerts1,
            descr: L10n.Ux.Home.alerts2
        )
    ]

    lazy var items: Driver<[HomeItemViewData]> = alertRepo.alerts
        .startWith([])
        .map { alerts in alerts.filter { !$0.isRead }}
        .distinctUntilChanged()
        .map { alerts in
            Self.items.updateNotifications(with: alerts)
        }
        .observeOn(MainScheduler.instance)
        .asDriver(onErrorJustReturn: [])

    lazy var versionNameString = L10n.Ux.Home.Footer.version + ": " + envInfos.appVersionName
    lazy var buildString = L10n.Ux.Home.Footer.build + ": " + envInfos.appVersionCode

    private let disposeBag = DisposeBag()

    init(
        startPermissions: StartPermissions,
        rootNav: RootNav,
        alertRepo: AlertRepo,
        envInfos: EnvInfos) {

        self.rootNav = rootNav
        self.alertRepo = alertRepo
        self.envInfos = envInfos

        startPermissions.granted.subscribe(onNext: { granted in
            log.d("Start permissions granted: \(granted)")
        }).disposed(by: disposeBag)

        startPermissions.request()

        itemSelectTrigger
            .subscribe(onNext: { item in
                switch item.id {
                case .reportSymptoms: rootNav.navigate(command: .to(destination: .symptomReport))
                case .alerts: rootNav.navigate(command: .to(destination: .alerts))
                }
            }).disposed(by: disposeBag)
    }

    func debugTapped() {
        rootNav.navigate(command: .to(destination: .debug))
    }

    func quizTapped() {
        rootNav.navigate(command: .to(destination: .symptomReport))
    }

    func seeAlertsTapped() {
        rootNav.navigate(command: .to(destination: .alerts))
    }

    func onClick(item: HomeItemViewData) {
        itemSelectTrigger.accept(item)
    }
}

private extension Array where Element == HomeItemViewData {

    func updateNotifications(with alerts: [Alert]) -> [HomeItemViewData] {
        map { item in
            if item.id == .alerts {
                if alerts.isEmpty {
                    return item
                } else {
                    var item = item
                    let alertTitle = alertsNotificationTitle(alertsCount: alerts.count)
                    item.notification = HomeItemNotification(text: alertTitle)
                    return item
                }
            } else {
                return item
            }
        }
    }
}

private func alertsNotificationTitle(alertsCount: Int) -> String {
    if alertsCount == 1 {
        return L10n.Home.Items.Alerts.Notification.one
    } else {
        return L10n.Home.Items.Alerts.Notification.some(alertsCount)
    }
}
