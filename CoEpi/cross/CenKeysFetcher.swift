import Foundation
import RxSwift
import os.log

class CenKeysFetcher {
    private let api: CoEpiApi

    lazy var keys: Observable<[CENKey]> = Observable<Int>
        // TODO 1 min just for testing
        .timer(.seconds(0), period: .seconds(3600), scheduler: MainScheduler.instance)
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
