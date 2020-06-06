import Foundation
import RxSwift
import os.log

class PeriodicCenKeysFetcher {
    private let api: CoEpiApi

    lazy var keys: Observable<[CENKey]> = Observable<Int>
        .timer(.seconds(0), period: .seconds(3600), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
        .flatMapLatest { [api] _ in
            api.getCenKeys()
        }
        .map { strings in
            strings.map { CENKey(cenKey: $0) }
        }

    init(api: CoEpiApi) {
        self.api = api
    }
}
