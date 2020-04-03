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
}

class CoEpiRepoImpl: CoEpiRepo {
    private let cenRepo: CENRepo
    private let api: Api
    private let cenMatcher: CenMatcher
    private let cenKeyDao: CENKeyDao

    let reports: Observable<[ReceivedCenReport]>

    // last time (unix timestamp) the CENKeys were requested
    // TODO has to be updated. In Android it's currently also not updated.
    private static var lastCENKeysCheck: Int64 = 0

    private let disposeBag = DisposeBag()

    init(cenRepo: CENRepo, api: Api, keysFetcher: CenKeysFetcher, cenMatcher: CenMatcher, cenKeyDao: CENKeyDao) {
        self.cenRepo = cenRepo
        self.api = api
        self.cenMatcher = cenMatcher
        self.cenKeyDao = cenKeyDao

        reports = keysFetcher.keys
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { keys in
                os_log("Fetched keys from API: %@", log: servicesLog, type: .debug, "\(keys)")
            })

            // Filter matching keys
            .map { keys -> [CENKey] in keys.compactMap { key in
                if (cenMatcher.hasMatches(key: key, maxTimestamp: CoEpiRepoImpl.lastCENKeysCheck)) {
                    return key
                } else {
                    return nil
                }
            }}

            .do(onNext: { matchedKeys in
                if !matchedKeys.isEmpty {
                    os_log("Matches found for keys: %@", log: servicesLog, type: .debug, "\(matchedKeys)")
                } else {
                    os_log("No matches found for keys", log: servicesLog, type: .debug)
                }
            })

            // Retrieve reports for matching keys
            .flatMap { matchedKeys -> Observable<[ReceivedCenReport]> in
                let requests: [Observable<ReceivedCenReport>] = matchedKeys.map {
                    api.getCenReport(cenKey: $0).asObservable()
                }
                return Observable.merge(requests).toArray().asObservable()
            }
            .observeOn(MainScheduler.instance) // TODO switch to main only in view models
            .share()

        reports.subscribe().disposed(by: disposeBag)
    }

    func storeObservedCen(cen: CEN) {
        if !(cenRepo.insert(cen: cen)) {
            os_log("Observed CEN already in DB: %@", log: servicesLog, type: .debug, "\(cen)")
        }
    }

    // TODO clarify with Rust lib, does it store the keys or we pass them
    func sendReport(report: CenReport) -> Completable {
        if let lastCenKey = cenKeyDao.getLatestCENKey() { // TODO last n keys?
            return api.postCenReport(cenReport: MyCenReport(report: report, keys: lastCenKey.cenKey))
        } else {
            return Completable.error(RepoError.userHasNoCenKeys)
        }
    }
}
