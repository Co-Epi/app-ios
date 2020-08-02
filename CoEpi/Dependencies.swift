import Dip
import Foundation

class Dependencies {
    func createContainer() -> DependencyContainer {
        let container = DependencyContainer()

        let fileSystem: FileSystem = FileSystemImpl()
        container.register { fileSystem }

        // NOTE: Has to be initialized before everything else (besides FileSystem)
        // to ensure that core services are available to all dependencies.
        // TODO: consider initializing dependencies asynchronously.
        registerAndInitNativeCore(container: container, fileSystem: fileSystem)

        let alertFilterSettings = AlertFilterSettings(
            durationSecondsLargerThan: 300,
            distanceShorterThan: Measurement(value: 10, unit: .feet)
        )

        registerLogic(container: container)
        registerWiring(container: container, alertFilterSettings: alertFilterSettings)
        registerViewModels(container: container, alertFilterSettings: alertFilterSettings)
        registerRepos(container: container)
        registerServices(container: container)
        registerBle(container: container)
        registerSystem(container: container)

        // Throws if components fail to instantiate
        try! container.bootstrap()

        return container
    }

    private func registerAndInitNativeCore(container: DependencyContainer, fileSystem: FileSystem) {
        let nativeCore = NativeCore()

        let coreDatabasePath =
            fileSystem
                .coreDatabasePath()
                .expect("CRITICAL: Couldn't get path to core database:")
        let bootstrapResult = nativeCore.bootstrap(dbPath: coreDatabasePath)
        if bootstrapResult.isFailure() {
            fatalError("CRITICAL: Couldn't initialize core: \(bootstrapResult)")
        }

        container
            .register(.singleton) { nativeCore as ServicesBootstrapper }
        container
            .register(.singleton) { nativeCore as AlertsApi }
        container
            .register(.singleton) { nativeCore as SymptomsInputManager }
        container
            .register(.singleton) { nativeCore as ObservedTcnsRecorder }
        container
            .register(.singleton) { nativeCore as TcnGenerator }
    }

    private func registerViewModels(container: DependencyContainer,
                                    alertFilterSettings: AlertFilterSettings)
    {
        container.register { HomeViewModel(startPermissions: try container.resolve(),
                                           rootNav: try container.resolve(),
                                           alertRepo: try container.resolve(),
                                           envInfos: try container.resolve()) }
        container.register { OnboardingViewModel() }

        container
            .register { ThankYouViewModel(
                rootNav: try container.resolve()) }
        container
            .register { BreathlessViewModel(
                symptomFlowManager: try container.resolve()) }
        container
            .register { CoughTypeViewModel(
                symptomFlowManager: try container.resolve()) }
        container
            .register { CoughDaysViewModel(
                symptomFlowManager: try container.resolve()) }
        container
            .register { CoughHowViewModel(
                symptomFlowManager: try container.resolve()) }
        container
            .register { FeverDaysViewModel(
                symptomFlowManager: try container.resolve()) }
        container
            .register { FeverTodayViewModel(
                symptomFlowManager: try container.resolve()) }
        container
            .register { FeverWhereViewModel(
                symptomFlowManager: try container.resolve()) }
        container
            .register { FeverTempViewModel(
                symptomFlowManager: try container.resolve()) }
        container
            .register { SymptomReportViewModel(
                symptomRepo: try container.resolve(),
                rootNav: try container.resolve(),
                symptomFlowManager: try container.resolve()
            ) }

        container
            .register { OnboardingWireframe(container: container) }
        container
            .register { SymptomStartDaysViewModel(
                symptomFlowManager: try container.resolve()) }

        container
            .register { AlertsViewModel(
                alertRepo: try container.resolve(),
                nav: try container.resolve()
            ) }

        container
            .register { DebugBleViewModel(
                bleAdapter: try container.resolve()) }
        container
            .register { LogsViewModel(
                log: cachingLog, clipboard: try container.resolve(),
                envInfos: try container.resolve()
            ) }

        container.register { AlertDetailsViewModel(pars: $0,
                                                   alertRepo: try container.resolve(),
                                                   nav: try container.resolve(),
                                                   email: try container.resolve(),
                                                   unitsFormatter: try container.resolve()) }

        container.register { UserSettingsViewModel(kvStore: try container.resolve(),
                                                   alertFilterSettings: alertFilterSettings,
                                                   envInfos: try container.resolve(),
                                                   email: try container.resolve(),
                                                   unitsFormatter: try container.resolve()) }
    }

    private func registerRepos(container: DependencyContainer) {
        container
            .register(.singleton) { SymptomRepoImpl(
                inputManager: try container.resolve()) as SymptomRepo }
        container
            .register(.singleton) { AlertRepoImpl(
                alertsApi: try container.resolve(),
                notificationShower: try container.resolve(),
                alertFilters: try container.resolve()
            ) as AlertRepo
            }
    }

    private func registerServices(container: DependencyContainer) {
        container
            .register(.singleton) { AppBadgeUpdaterImpl() as AppBadgeUpdater }
        container
            .register(.singleton) { NotificationShowerImpl() as NotificationShower }

        container
            .register(.singleton) { BackgroundTasksManager() }
        container
            .register(.eagerSingleton) { FetchAlertsBackgroundRegisterer(
                tasksManager: try container.resolve(),
                alertRepo: try container.resolve()
            ) }
        container.register(.eagerSingleton) { NotificationsDelegate(
            rootNav: try container.resolve()) }
    }

    private func registerLogic(container _: DependencyContainer) {
//        container.register(.eagerSingleton) { AlertNotificationsShower(alertsRepo: try container.resolve()) }
    }

    private func registerWiring(
        container: DependencyContainer,
        alertFilterSettings: AlertFilterSettings
    ) {
        container
            .register(.eagerSingleton) { ScannedCensHandler(
                bleAdapter: try container.resolve(),
                tcnsRecorder: try container.resolve()
            ) }
        container
            .register(.eagerSingleton) { PeriodicAlertsFetcher(
                alertRepo: try container.resolve()) }
        container
            .register(.eagerSingleton) { RootNav() }

        container
            .register(.singleton) { SymptomRouterImpl(
                rootNav: try container.resolve()) as SymptomRouter }
        container
            .register(.singleton) { SymptomFlowManager(
                symptomRouter: try container.resolve(),
                rootNavigation: try container.resolve(),
                inputsManager: try container.resolve()
            ) }
        container.register {
            ObservableAlertFiltersImpl(
                kvStore: try container.resolve(),
                filterSettings: alertFilterSettings
            ) as ObservableAlertFilters
        }
    }

    private func registerBle(container: DependencyContainer) {
        container
            .register(.eagerSingleton) { BleAdapter(
                tcnGenerator: try container.resolve()) }
    }

    private func registerSystem(container: DependencyContainer) {
        container
            .register(.singleton) { KeyValueStoreImpl() as KeyValueStore }
        container
            .register(.singleton) { StartPermissionsImpl() as StartPermissions }
        container
            .register(.singleton) { Clipboard() }
        container
            .register(.singleton) { EnvInfos() }
        container
            .register(.singleton) { EmailImpl() as Email }
        container.register(.singleton) { ObservableKeyValueStoreImpl(
            keyValueStore: try container.resolve()) as ObservableKeyValueStore
        }
        container.register(.eagerSingleton) { LocaleProviderImpl() as LocaleProvider }
        container.register(.eagerSingleton) {
            UnitsFormatterImpl(localeProvider: try container.resolve()) as UnitsFormatter
        }
    }
}
