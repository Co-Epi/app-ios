import Foundation
import RxSwift
import os.log

// NOTE: This is interace for possible Rust shared library
// Reports storage unclear, most likely shared lib forwards api call result, we cache in Realm
// For now the caching happens _in_ CoEpiRepo

protocol CoEpiRepo {
    // Infection reports fetched periodically from the API
    var reports: Observable<[ReceivedCenReport]> { get }

    // Store CEN from other device
    func storeObservedCen(cen: CEN)

    // Send symptoms report
    func sendReport(report: CenReport) -> Completable

    func updateReports() -> Single<[ReceivedCenReport]>
}

class CoEpiRepoImpl: CoEpiRepo {
    private let cenRepo: CENRepo
    private let api: CoEpiApi
    private let cenMatcher: CenMatcher
    private let cenKeyDao: CENKeyDao
    private let reportsHandler: MatchingReportsHandler

    let reports: Observable<[ReceivedCenReport]>

    // last time (unix timestamp) the CENKeys were requested
    // TODO has to be updated. In Android it's currently also not updated.
    private static var lastCENKeysCheck: Int64 = 0

    private let disposeBag = DisposeBag()

    private var matchingStartTime: CFAbsoluteTime? = nil

    init(cenRepo: CENRepo, api: CoEpiApi, periodicKeysFetcher: PeriodicCenKeysFetcher, cenMatcher: CenMatcher,
         cenKeyDao: CENKeyDao, reportsHandler: MatchingReportsHandler) {

        self.cenRepo = cenRepo
        self.api = api
        self.cenMatcher = cenMatcher
        self.cenKeyDao = cenKeyDao
        self.reportsHandler = reportsHandler

        reports = reportsWith(keys: periodicKeysFetcher.keys, cenMatcher: cenMatcher, api: api,
                              reportsHandler: reportsHandler)
        reports.share().subscribe().disposed(by: disposeBag)
    }

    func updateReports() -> Single<[ReceivedCenReport]> {
        let keysObservable = api.getCenKeys().map {
            $0.map { CENKey(cenKey: $0) }
        }.asObservable()

        return reportsWith(keys: keysObservable, cenMatcher: cenMatcher, api: api, reportsHandler: reportsHandler)
            .asSingle()
    }

    func storeObservedCen(cen: CEN) {
        if !(cenRepo.insert(cen: cen)) {
            os_log("Observed CEN already in DB: %@", log: servicesLog, type: .debug, "\(cen)")
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
                         reportsHandler: MatchingReportsHandler) -> Observable<[ReceivedCenReport]> {
    // Benchmarking
    var matchingStartTime: CFAbsoluteTime?

    return keys
        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .do(onNext: { keys in
            matchingStartTime = CFAbsoluteTimeGetCurrent()
            os_log("Fetched keys from API (%d)", log: servicesLog, type: .debug, keys.count)
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
            return Observable.zip(requests) { (reports: [[ReceivedCenReport]]) in
                reports.flatMap { $0 }
            }
        }

        .do(onNext: { reports in
            reportsHandler.handleMatchingReports(reports: reports)
        })

        .observeOn(MainScheduler.instance) // TODO switch to main only in view models
}
