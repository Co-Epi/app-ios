import RxSwift
import BackgroundTasks
import Action

class FetchAlertsBackgroundTask: BackgroundTask {

    let identifier: String = "org.coepi.tcn_matching"

    let scheduleInterval: TimeInterval = 60 * 60 // 1h

    private let alertRepo: AlertRepo

    private let fetchAlertsAction: CocoaAction

    init(alertRepo: AlertRepo) {
        self.alertRepo = alertRepo

        let fetchAlertsAction: CocoaAction = Action { [alertRepo] in
            fetchReportsCompletable(alertRepo: alertRepo)
                .asVoidObservable()
        }
        self.fetchAlertsAction = fetchAlertsAction

    }

    func execute(task: BGProcessingTask) {
        log.d("Starting fetch alerts bg task...")

        fetchAlertsAction.execute()
    }
}

private func fetchReportsCompletable(alertRepo: AlertRepo) -> Completable {
    Completable.create { emitter -> Disposable in
        alertRepo.updateReports()
        emitter(.completed)
        return Disposables.create {}
    }
    .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
}
