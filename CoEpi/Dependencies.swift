import Foundation
import Dip

class Dependencies {

    func createContainer() -> DependencyContainer {

        let container = DependencyContainer()

        let fileSystem: FileSystem = FileSystemImpl()
        container.register { fileSystem }

        // NOTE: Has to be initialized before everything else (besides FileSystem)
        // to ensure that core services are available to all dependencies.
        // TODO consider initializing dependencies asynchronously.
        registerAndInitNativeCore(container: container, fileSystem: fileSystem)

        registerLogic(container: container)
        registerViewModels(container: container)
        registerDaos(container: container)
        registerRepos(container: container)
        registerServices(container: container)
        registerBle(container: container)
        registerWiring(container: container)
        registerSystem(container: container)

        // Throws if components fail to instantiate
        try! container.bootstrap()

        return container
    }

    private func registerAndInitNativeCore(container: DependencyContainer, fileSystem: FileSystem) {
        let nativeCore = NativeCore()

        let coreDatabasePath = fileSystem.coreDatabasePath().expect("CRITICAL: Couldn't get path to core database:")
        let bootstrapResult = nativeCore.bootstrap(dbPath: coreDatabasePath)
        if bootstrapResult.isFailure() {
            fatalError("CRITICAL: Couldn't initialize core: \(bootstrapResult)")
        }

        container.register(.singleton) { nativeCore as ServicesBootstrapper }
        container.register(.singleton) { nativeCore as AlertsFetcher }
        container.register(.singleton) { nativeCore as SymptomsInputManager }
        container.register(.singleton) { nativeCore as ObservedTcnsRecorder }

    }

    private func registerViewModels(container: DependencyContainer) {
        container.register { HomeViewModel(startPermissions: try container.resolve(), rootNav: try container.resolve()) }
        //container.register { OnboardingWireframe(container: container) }
        container.register { OnboardingViewModel() }
        
        
        container.register { ThankYouViewModel() }
        container.register { BreathlessViewModel(inputsManager: try container.resolve()) }
        container.register { CoughTypeViewModel(inputsManager: try container.resolve()) }
        container.register { CoughDaysViewModel(inputsManager: try container.resolve()) }
        container.register { CoughHowViewModel(inputsManager: try container.resolve()) }
        container.register { FeverDaysViewModel(inputsManager: try container.resolve()) }
        container.register { FeverTodayViewModel(inputsManager: try container.resolve()) }
        container.register { FeverWhereViewModel(inputsManager: try container.resolve()) }
        container.register { FeverWhereViewModelOther() }
        container.register { FeverTempViewModel(inputsManager: try container.resolve()) }
        container.register { SymptomReportViewModel() }
        container.register { OnboardingViewModel() }
        container.register { OnboardingWireframe(container: container) }
        container.register { SymptomStartDaysViewModel() }
        
        container.register { HealthQuizViewModel(symptomRepo: try container.resolve(), rootNav: try container.resolve(),
                                                 inputsManager: try container.resolve()) }
        container.register { AlertsViewModel(alertRepo: try container.resolve()) }

        container.register { DebugViewModel(bleAdapter: try container.resolve(),
                                            cenKeyDao: try container.resolve()) }
    }

    private func registerDaos(container: DependencyContainer) {
        container.register(.singleton) { RealmProvider() }
        container.register(.singleton) { RealmRawAlertDao(realmProvider: try container.resolve()) as RawAlertDao }
        container.register(.singleton) { RealmCENDao(realmProvider: try container.resolve()) as CENDao }
        container.register(.eagerSingleton) { RealmCENReportDao(realmProvider: try container.resolve()) as CENReportDao }
        container.register(.singleton) { RealmCENKeyDao(realmProvider: try container.resolve(),
                                                        cenLogic: try container.resolve()) as CENKeyDao }
    }

    private func registerRepos(container: DependencyContainer) {
        container.register(.singleton) { SymptomRepoImpl(inputManager: try container.resolve()) as SymptomRepo }
        container.register(.singleton) { AlertRepoImpl(cenReportDao: try container.resolve(),
                                                       alertsFetcher: try container.resolve(),
                                                       alertDao: try container.resolve()) as AlertRepo }
        container.register(.singleton) { CENRepoImpl(cenDao: try container.resolve()) as CENRepo }
        container.register(.singleton) { CENKeyRepoImpl(cenKeyDao: try container.resolve()) as CENKeyRepo }
    }

    private func registerServices(container: DependencyContainer) {
        container.register(.singleton) { ContactReceivedHandler(cenKeyRepo: try container.resolve(),
                                                                cenLogic: try container.resolve()) }
        container.register(.singleton) { AppBadgeUpdaterImpl() as AppBadgeUpdater }
        container.register(.singleton) { NotificationShowerImpl() as NotificationShower }

        container.register(.singleton) { BackgroundTasksManager() }
        container.register(.eagerSingleton) { FetchAlertsBackgroundRegisterer(tasksManager: try container.resolve(),
                                                                              alertRepo: try container.resolve()) }
        container.register(.singleton) { MatchingReportsHandlerImpl(reportsDao: try container.resolve(),
                                                                   notificationShower: try container.resolve(),
                                                                   appBadgeUpdater: try container.resolve())
            as MatchingReportsHandler }
        container.register(.eagerSingleton) { NotificationsDelegate(rootNav: try container.resolve()) }
    }


    private func registerLogic(container: DependencyContainer) {
        container.register(.singleton) { CenLogic() }
//        container.register(.eagerSingleton) { AlertNotificationsShower(alertsRepo: try container.resolve()) }
    }

    private func registerWiring(container: DependencyContainer) {
        container.register(.eagerSingleton) { ScannedCensHandler(bleAdapter: try container.resolve(),
                                                                 tcnsRecorder: try container.resolve())}
        container.register(.eagerSingleton) { PeriodicAlertsFetcher(alertRepo: try container.resolve()) }
        container.register(.singleton) { CenMatcherImpl(cenRepo: try container.resolve(),
                                                        cenLogic: try container.resolve()) as CenMatcher }
        container.register(.singleton) { MatchingReportsHandlerImpl(reportsDao: try container.resolve(),
                                                                   notificationShower: try container.resolve(),
                                                                   appBadgeUpdater: try container.resolve())
            as MatchingReportsHandler }
        container.register(.eagerSingleton) { RootNav() }
    }

    private func registerBle(container: DependencyContainer) {
        container.register(.eagerSingleton) { BleAdapter(cenReadHandler: try container.resolve()) }
    }

    private func registerSystem(container: DependencyContainer) {
        container.register(.singleton) { KeyValueStoreImpl() as KeyValueStore }
        container.register(.singleton) { StartPermissionsImpl() as StartPermissions }
    }
}
