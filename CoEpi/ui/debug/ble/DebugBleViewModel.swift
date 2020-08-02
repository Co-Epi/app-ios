import Foundation
import RxCocoa
import RxSwift

class DebugBleViewModel {
    let debugEntries: Driver<[DebugBleEntryViewData]>

    private let disposeBag = DisposeBag()

    init(bleAdapter: BleAdapter) {
        let combined = Observable.combineLatest(
            bleAdapter.myTcn.distinctUntilChanged().asSequence(),
            bleAdapter.discovered.map { $0.0 }.distinctUntilChanged().asSequence().map { $0.distinct() }
        )

        debugEntries = combined
            .map { myTcn, discovered in
                generateItems(myTcn: myTcn, discovered: discovered)
            }
            .asDriver(onErrorJustReturn: [])
    }
}

enum DebugBleEntryViewData {
    case header(String)
    case item(String)
}

private func generateItems(myTcn: [String], discovered: [Data]) -> [DebugBleEntryViewData] {
    items(header: "My TCN", items: myTcn)
        + items(header: "Discovered", items: discovered.map { $0.toHex() })
}

private func items(header: String, items: [String]) -> [DebugBleEntryViewData] {
    [.header(header)] + items.map { .item($0) }
}
