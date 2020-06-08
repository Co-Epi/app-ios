import Foundation
import RxSwift

class PeriodicAlertsFetcher {
    private let disposeBag = DisposeBag()

    init(alertRepo: AlertRepo) {
        Observable<Int>
            .timer(.seconds(0), period: .seconds(3600), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { _ in
                alertRepo.updateReports()
            })
            .disposed(by: disposeBag)
    }
}

private func fetchReportsCompletable(alertRepo: AlertRepo) -> Completable {
    Completable.create { emitter -> Disposable in
        alertRepo.updateReports()
        emitter(.completed)
        return Disposables.create {}
    }
}

