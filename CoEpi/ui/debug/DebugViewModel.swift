import Foundation
import RxSwift
import RxCocoa

class DebugViewModel {

    let debugEntries: Driver<[DebugEntryViewData]>

    private let disposeBag = DisposeBag()

    init(bleAdapter: BleAdapter, cenKeyDao: CENKeyDao, api: CoEpiApi) {
        let combined = Observable.combineLatest(
            cenKeyDao.generatedMyKey.asSequence().map { $0.distinct() },
            bleAdapter.myCen.asSequence().map { $0.distinct() },
            bleAdapter.discovered.asSequence().map { $0.distinct() }
        )

        debugEntries = combined
            .map { myKey, myCen, discovered in
                return generateItems(myKey: myKey, myCen: myCen, discovered: discovered)
            }
            .asDriver(onErrorJustReturn: [])
    }
}

enum DebugEntryViewData {
    case Header(String)
    case Item(String)
}

private func generateItems(myKey: [String], myCen: [String], discovered: [CEN]) -> [DebugEntryViewData] {
    return items(header: "My key", items: myKey)
        + items(header: "My CEN", items: myCen)
        + items(header: "Discovered", items: discovered.map{ $0.CEN })
}

private func items(header: String, items: [String]) -> [DebugEntryViewData] {
    [.Header(header)] + items.map{ .Item($0) }
}
