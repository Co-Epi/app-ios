import RxSwift
import os.log
import BackgroundTasks

class FetchAlertsBackgroundTask: BackgroundTask {

    let identifier: String = "org.coepi.tcn_matching"

    let scheduleInterval: TimeInterval = 15 * 60

    private let coEpiRepo: CoEpiRepo

    private let disposeBag = DisposeBag()

    init(coEpiRepo: CoEpiRepo) {
        self.coEpiRepo = coEpiRepo
    }

    func execute(task: BGProcessingTask) {
        coEpiRepo.updateReportsState.filter { $0.isComplete() }.subscribe { res in
            os_log("Got results in bg task... %{public}@", log: servicesLog, type: .debug, "\(res)")
            task.setTaskCompleted(success: true)
        }.disposed(by: disposeBag)

        os_log("Starting fetch alerts bg task...", log: servicesLog, type: .debug)
        coEpiRepo.updateReports()
    }
}
