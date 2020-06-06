import Foundation
import RxSwift
import os.log
import Action
import RxCocoa

// NOTE: This is interface for possible Rust shared library
// Reports storage unclear, most likely shared lib forwards api call result, we cache in Realm
// For now the caching happens _in_ CoEpiRepo

protocol CoEpiRepo {

    // Store CEN from other device
    func storeObservedCen(cen: CEN)

    // Send symptoms report
    func sendReport(report: CenReport) -> Completable

    // Trigger manually report update
    func updateReports()

    var updateReportsState: Observable<OperationState<CenReportUpdateResult>> { get }
}

struct CenReportUpdateResult {
    let timeSpent: TimeInterval
}

class CoEpiRepoImpl: CoEpiRepo {
    private let cenRepo: CENRepo
    private let api: CoEpiApi
    private let cenMatcher: CenMatcher
    private let cenKeyDao: CENKeyDao
    private let reportsHandler: MatchingReportsHandler

    // last time (unix timestamp) the CENKeys were requested
    // TODO has to be updated. In Android it's currently also not updated.
    private static var lastCENKeysCheck: Int64 = 0

    private let disposeBag = DisposeBag()

    private var matchingStartTime: CFAbsoluteTime? = nil

    private let updateReportsStateSubject: BehaviorSubject<OperationState<CenReportUpdateResult>> =
        BehaviorSubject(value: .notStarted)
    lazy var updateReportsState: Observable<OperationState<CenReportUpdateResult>> =
        updateReportsStateSubject.asObservable()

    private let manualReportsUpdateAction: CocoaAction

    private let manualReportsUpdateActionTrigger: PublishRelay<Void> = PublishRelay()

    init(cenRepo: CENRepo, api: CoEpiApi, periodicKeysFetcher: PeriodicCenKeysFetcher, cenMatcher: CenMatcher,
         cenKeyDao: CENKeyDao, reportsHandler: MatchingReportsHandler) {

        self.cenRepo = cenRepo
        self.api = api
        self.cenMatcher = cenMatcher
        self.cenKeyDao = cenKeyDao
        self.reportsHandler = reportsHandler

        reportsWith(keys: periodicKeysFetcher.keys, cenMatcher: cenMatcher, api: api,
                    reportsHandler: reportsHandler,
                    updateReportsStateSubject: updateReportsStateSubject)
            .subscribe()
            .disposed(by: disposeBag)

        let manualReportsUpdateAction: CocoaAction = Action { [updateReportsStateSubject] in
            let keysObservable = api.getCenKeys()
                .map { $0.map { CENKey(cenKey: $0) }}
                .asObservable()
            return reportsWith(keys: keysObservable, cenMatcher: cenMatcher, api: api, reportsHandler: reportsHandler,
                updateReportsStateSubject: updateReportsStateSubject).ignoreElements().asVoidObservable()
        }
        self.manualReportsUpdateAction = manualReportsUpdateAction

        manualReportsUpdateActionTrigger
            // Don't start update if already running
            .withLatestFrom(
                Observable.combineLatest(
                    manualReportsUpdateAction.executing,
                    updateReportsState.map { $0.isProgress() }
                ).map { manualExecuting, inProgress in
                    !manualExecuting && !inProgress
                }
            )
            .filter { $0 }
            .subscribe(onNext: { _ in
                manualReportsUpdateAction.execute()
            })
            .disposed(by: disposeBag)
    }

    func updateReports() {
        manualReportsUpdateActionTrigger.accept(())
    }

    func storeObservedCen(cen: CEN) {
        if !(cenRepo.insert(cen: cen)) {
            os_log("Stored new CEN in DB: %{public}@", log: bleLog, type: .debug, "\(cen)")
        } else {
            os_log("CEN was already in DB: %{public}@", log: bleLog, type: .debug, "\(cen)")
        }
    }

    // TODO clarify with Rust lib, does it store the keys or we pass them
    func sendReport(report: CenReport) -> Completable {
        switch cenKeyDao.generateAndStoreCENKey() {  // TODO last n keys?
        case .success(let key):
            // TODO clarify id
            return api.postCenReport(myCenReport: MyCenReport(id: "123", report: report, keys: [key.cenKey]))
        case .failure(let error):
            switch error {
            case .couldNotComputeKey: return .error(RepoError.couldNotComputeKey)
            case .database: return .error(RepoError.database)
            }
        }
    }
}

private func reportsWith(keys: Observable<[CENKey]>, cenMatcher: CenMatcher, api: CoEpiApi,
                         reportsHandler: MatchingReportsHandler,
                         updateReportsStateSubject: BehaviorSubject<OperationState<CenReportUpdateResult>>) -> Observable<[ReceivedCenReport]> {
    // Benchmarking
    var matchingStartTime: CFAbsoluteTime?
    var totalStartTime: CFAbsoluteTime?

    return keys
        .do(onSubscribe: {
            totalStartTime = CFAbsoluteTimeGetCurrent()
            updateReportsStateSubject.onNext(.progress)
        })

        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))

        .do(onNext: { keys in
            matchingStartTime = CFAbsoluteTimeGetCurrent()
            os_log("Fetched keys from API (%{public}d)", log: servicesLog, type: .debug, keys.count)
        })

//            // Uncomment this to benchmark a few keys quickly...
//            .map({ keys in
//                keys[0...2]
//            })

        // Filter matching keys
//            .map { keys -> [CENKey] in keys.compactMap { key in
//                if (cenMatcher.hasMatches(key: key, maxTimestamp: CoEpiRepoImpl.lastCENKeysCheck)) {
//                    return key
//                } else {
//                    return nil
//                }
//            }}

        .map{ keys -> [CENKey] in cenMatcher.matchLocalFirst(keys: keys, maxTimestamp: .now()) }

        .do(onNext: { matchedKeys in
            if let matchingStartTime = matchingStartTime {
                let time = CFAbsoluteTimeGetCurrent() - matchingStartTime
                os_log("Took %.2f to match keys", log: servicesLog, type: .debug, time)
            }
            if !matchedKeys.isEmpty {
                os_log("Matches found for [%{public}d] keys: %{public}@", log: servicesLog, type: .debug, matchedKeys.count ,"\(matchedKeys)")
            } else {
                os_log("No matches found for keys", log: servicesLog, type: .debug)
            }
        })

        // Retrieve reports for matching keys
        .flatMap { matchedKeys -> Observable<[ReceivedCenReport]> in
            let requests: [Observable<[ReceivedCenReport]>] = matchedKeys.map {
                api.getCenReports(cenKey: $0)
                    .map({ apiCenReports in
                        apiCenReports.map { ReceivedCenReport(report: $0.toCenReport()) }
                    })
                    .asObservable()
            }

            if requests.isEmpty {
                return Observable.just([])
            } else {
                return Observable.zip(requests) { (reports: [[ReceivedCenReport]]) in
                    reports.flatMap { $0 }
                }
            }
        }

        .do(onNext: { reports in
            reportsHandler.handleMatchingReports(reports: reports)
        })

        .do(onNext: { reports in
            if let totalStartTime = totalStartTime {
                let time = CFAbsoluteTimeGetCurrent() - totalStartTime
                os_log("Took %{public}.2f to retrieve reports", log: servicesLog, type: .debug, time)
                updateReportsStateSubject.onNext(.success(data: CenReportUpdateResult(timeSpent: time)))
            }
            updateReportsStateSubject.onNext(.notStarted)
        })

        .do(onError: { error in
            os_log("Error retrieving reports: %{public}@", log: servicesLog, type: .debug, "\(error)")
            updateReportsStateSubject.onNext(.failure(error: error))
        })

        .observeOn(MainScheduler.instance) // TODO switch to main only in view models
}
