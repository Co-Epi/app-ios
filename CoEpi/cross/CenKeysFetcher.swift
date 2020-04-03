import Foundation
import RxSwift
import os.log

class CenKeysFetcher {
    private let api: Api

    lazy var keys: Observable<[CENKey]> = Observable<Int>
        .timer(.seconds(0), period: .seconds(60), scheduler: MainScheduler.instance)
        // TODO 1 min just for testing
        .flatMapLatest { [api] _ in
            api.getCenKeys()
        }
        .map { strings in
            strings.map { CENKey(cenKey: $0) }
        }

    init(api: Api) {
        self.api = api
    }
}
