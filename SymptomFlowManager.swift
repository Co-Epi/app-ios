import RxCocoa
import RxSwift

class SymptomFlowManager {
    let symptomRouter: SymptomRouter
    let rootNavigation: RootNav
    let inputsManager: SymptomsInputManager
    let notificationShower: NotificationShower

    var symptomFlow: SymptomFlow?

    private let finishFlowTrigger: PublishRelay<Void> = PublishRelay()

    private let disposeBag = DisposeBag()

    private let submitSymptomsStateSubject: PublishRelay<VoidOperationState> = PublishRelay()
    lazy var submitSymptomsState: Observable<VoidOperationState> = submitSymptomsStateSubject
        .asObservable()
        .startWith(.notStarted)

    init(
        symptomRouter: SymptomRouter,
        rootNavigation: RootNav,
        inputsManager: SymptomsInputManager,
        notificationShower: NotificationShower
    ) {
        self.symptomRouter = symptomRouter
        self.rootNavigation = rootNavigation
        self.inputsManager = inputsManager
        self.notificationShower = notificationShower

        finishFlowTrigger
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { [submitSymptomsStateSubject] _ in
                submitSymptomsStateSubject.accept(.progress)
            })
            .map { inputsManager.submit() }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                self?.handleSubmitReportResult(result)
            })
            .disposed(by: disposeBag)
    }

    func startFlow(
        symptomIds: [SymptomId])
        -> Bool {
        if symptomIds.isEmpty {
            log.d("Symptoms ids is empty")
            return false
        }

        inputsManager.setSymptoms(Set(symptomIds)).expect()
        symptomFlow = .create(symptomIds: symptomIds)

        updateNavigation()
        return true
    }

    func navigateForward() {
        guard let symptomFlow = symptomFlow else {
            // Navigate forward is called from screens in the input flow
            fatalError("Can't navigate forward if there's no input flow")
        }

        if symptomFlow.next() == nil {
            finishFlowTrigger.accept(())
        } else {
            updateNavigation()
        }
    }

    func updateNavigation() {
        guard let symptomFlow = symptomFlow else {
            log.d("No symptom inputs. Showing thanks screen.")
            finishFlowTrigger.accept(())
            return
        }

        rootNavigation.navigate(
            command: .to(destination: symptomRouter.destination(step: symptomFlow.currentStep)))
    }

    func handleSubmitReportResult(
        _ result: Result<Void,
            ServicesError>) {
        switch result {
        case .success:
            submitSymptomsStateSubject.accept(.success(data: ()))
            rootNavigation.navigate(command: .to(destination: .thankYou))
            clear()
        case let .failure(e):
            submitSymptomsStateSubject.accept(.failure(error: e))
            // TODO: user friendly / localized error message (and retry etc)
            print(e)
//            uiNotifier.notify(Failure(it.message ?? "Unknown error"))
        }
        submitSymptomsStateSubject.accept(.notStarted)
    }

    // NOTE: With current back handling, based on willMove(toParent parent: UIViewController?)
    // this will be called too when navigating back programmatically from thanks screen to start
    // (at least for the last view controller on the stack). We ignore this event with guard (at this
    // point flow has been cleared).
    func onBack() {
        guard let symptomFlow = symptomFlow else {
            return
        }
        if symptomFlow.previous() == nil {
            log.d("No previous step.")
        }
    }

    func clear() {
        symptomFlow = nil
        inputsManager.clear().expect()
        //clear notif for that day
        notificationShower.cancelReminderNotificationForTheDay()
    }
}

extension SymptomFlowManager {
    func setSymptoms(_ input: Set<SymptomId>) -> Result<Void, ServicesError> {
        inputsManager.setSymptoms(input)
    }

    func setCoughType(
        _ input: UserInput<SymptomInputs.Cough.CoughType>)
        -> Result<Void, ServicesError> {
        inputsManager.setCoughType(input)
    }

    func setCoughDays(
        _ input: UserInput<SymptomInputs.Days>)
        -> Result<Void, ServicesError> {
        inputsManager.setCoughDays(input)
    }

    func setCoughStatus(
        _ input: UserInput<SymptomInputs.Cough.Status>)
        -> Result<Void, ServicesError> {
        inputsManager.setCoughStatus(input)
    }

    func setBreathlessnessCause(
        _ input: UserInput<SymptomInputs.Breathlessness.Cause>)
        -> Result<Void, ServicesError> {
        inputsManager.setBreathlessnessCause(input)
    }

    func setFeverDays(
        _ input: UserInput<SymptomInputs.Days>)
        -> Result<Void, ServicesError> {
        inputsManager.setFeverDays(input)
    }

    func setFeverTakenTemperatureToday(
        _ input: UserInput<Bool>)
        -> Result<Void, ServicesError> {
        inputsManager.setFeverTakenTemperatureToday(input)
    }

    func setFeverTakenTemperatureSpot(
        _ input: UserInput<SymptomInputs.Fever.TemperatureSpot>)
        -> Result<Void, ServicesError> {
        inputsManager.setFeverTakenTemperatureSpot(input)
    }

    func setFeverHighestTemperatureTaken(
        _ input: UserInput<Temperature>)
        -> Result<Void, ServicesError> {
        inputsManager.setFeverHighestTemperatureTaken(input)
    }

    func setEarliestSymptomStartedDaysAgo(
        _ input: UserInput<Int>)
        -> Result<Void, ServicesError> {
        inputsManager.setEarliestSymptomStartedDaysAgo(input)
    }

    func submit()
        -> Result<Void, ServicesError> {
        inputsManager.submit()
    }
}
