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
            bleAdapter.discovered.asSequence().map { $0.distinct() },
            bleAdapter.peripheralWasRead.asSequence().map { $0.distinct() },
            bleAdapter.centralDidWrite.asSequence().map { $0.distinct() },
            bleAdapter.peripheralWasWrittenTo.asSequence().map { $0.distinct() }
        )

        debugEntries = combined
            .map { myKey, myCen, discovered, peripheralWasRead, centralDidWrite, peripheralWasWrittenTo in
                return generateItems(myKey: myKey, myCen: myCen, discovered: discovered, peripheralWasRead: peripheralWasRead,
                                     centralDidWrite: centralDidWrite, peripheralWasWrittenTo: peripheralWasWrittenTo)
            }
            .asDriver(onErrorJustReturn: [])
    }
}

enum DebugEntryViewData {
    case Header(String)
    case Item(String)
}

private func generateItems(myKey: [String], myCen: [String], discovered: [CEN], peripheralWasRead: [String],
                           centralDidWrite: [String], peripheralWasWrittenTo: [String]) -> [DebugEntryViewData] {
    return items(header: "My key", items: myKey)
        + items(header: "My CEN", items: myCen)
        + items(header: "Discovered", items: discovered.map{ $0.CEN })
        + items(header: "Peripheral was read", items: peripheralWasRead)
        + items(header: "Central did write", items: centralDidWrite)
        + items(header: "Peripheral was written to", items: peripheralWasWrittenTo)
}

private func items(header: String, items: [String]) -> [DebugEntryViewData] {
    [.Header(header)] + items.map{ .Item($0) }
}
