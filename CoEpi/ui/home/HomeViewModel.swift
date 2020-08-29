import RxCocoa
import RxSwift

enum HomeItemId {
    case reportSymptoms, alerts, howItWorks
}

struct HomeItemNotification {
    let text: String
}

class HomeItemViewData {
    let id: HomeItemId
    let descr: String
    var notification: HomeItemNotification?

    init(id: HomeItemId, descr: String, notification: HomeItemNotification? = nil) {
        self.id = id
        self.descr = descr
        self.notification = notification
    }
}

class HomeTitledItemViewData: HomeItemViewData {
    let title: String
    init(id: HomeItemId, title: String, descr: String, notification: HomeItemNotification? = nil) {
        self.title = title
        super.init(id: id, descr: descr, notification: notification)
    }
}

class HomeViewModel {
    private let rootNav: RootNav
    private let alertRepo: AlertRepo
    private let envInfos: EnvInfos

    let title = L10n.Ux.Home.title

    private let itemSelectTrigger = PublishRelay<HomeItemViewData>()

    private static let items = [
        HomeTitledItemViewData(
            id: .reportSymptoms,
            title: L10n.Ux.Home.report1,
            descr: L10n.Ux.Home.report2
        ),
        HomeTitledItemViewData(
            id: .alerts,
            title: L10n.Ux.Home.alerts1,
            descr: L10n.Ux.Home.alerts2
        ),
        HomeItemViewData(
            id: .howItWorks,
            descr: L10n.Home.Items.HowCoepiWorks.description
        )
    ]

    lazy var items: Driver<[HomeItemViewData]> = alertRepo.alerts
        .startWith([])
        .map { alerts in alerts.filter { !$0.isRead }}
        .distinctUntilChanged()
        .map { alerts in
            // TODO generate items here, don't manipulate variable
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
        envInfos: EnvInfos
    ) {
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
                case .howItWorks: rootNav.navigate(command: .to(destination: .howItWorks,
                                                                mode: .modal))
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

    func onSettingsTap() {
        rootNav.navigate(command: .to(destination: .settings))
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
                    item.notification = nil
                    return item
                } else {
                    let item = item
                    item.notification = HomeItemNotification(text: "\(alerts.count)")
                    return item
                }
            } else {
                return item
            }
        }
    }
}
