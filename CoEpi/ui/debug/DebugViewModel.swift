import Foundation
import RxSwift
import RxCocoa

class DebugViewModel {

    let debugEntries: Driver<[DebugEntryViewData]>

    private let disposeBag = DisposeBag()

    init(bleAdapter: BleAdapter) {
        let combined = Observable.combineLatest(
            bleAdapter.myTcn.distinctUntilChanged().asSequence(),
            bleAdapter.discovered.distinctUntilChanged().asSequence().map { $0.distinct() }
        )

        debugEntries = combined
            .map { myTcn, discovered in
                return generateItems(myTcn: myTcn, discovered: discovered)
            }
            .asDriver(onErrorJustReturn: [])
    }
}

enum DebugEntryViewData {
    case Header(String)
    case Item(String)
}

private func generateItems(myTcn: [String], discovered: [Data]) -> [DebugEntryViewData] {
    items(header: "My TCN", items: myTcn)
        + items(header: "Discovered", items: discovered.map { $0.toHex() })
}

private func items(header: String, items: [String]) -> [DebugEntryViewData] {
    [.Header(header)] + items.map{ .Item($0) }
}
