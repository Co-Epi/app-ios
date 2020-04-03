import Foundation
import RxSwift
import RxCocoa

class DebugViewModel {

    let debugEntries: Driver<[DebugEntryViewData]>

    init(bleAdapter: BleAdapter, api: Api) {


        //TESTING NETWORK
        print ("Testing Networking at lines 14 - 21 in DebugViewModel.swift")
        api.getCenKeys()
            .subscribe { print($0) }
        
        api.getCenReport(cenKey: CENKey(cenKey: "17FA287EBE6B42A3859A60C12CF71394"))
            .subscribe { print($0) }

        api.postCenReport(cenReport: CENReport(id: "80d2910e783ab87837b444c224a31c9745afffaaacd4fb6eacf233b5f30e3140", report: "c2V2ZXJlIGZldmVyLGNvdWdoaW5nLGhhcmQgdG8gYnJlYXRoZQ==", timestamp: Int64(Date().timeIntervalSince1970)))
            .subscribe { print($0) }
        //TESTING NETWORK

        let discovered = bleAdapter.discovered
            .scan([]) { acc, element in acc + [element] }

        let peripheralWasRead = bleAdapter.peripheralWasRead
            .scan([]) { acc, element in acc + [element] }

        let centralDidWrite = bleAdapter.centralDidWrite
            .scan([]) { acc, element in acc + [element] }

        let peripheralWasWrittenTo = bleAdapter.peripheralWasWrittenTo
            .scan([]) { acc, element in acc + [element] }

        let combined = Observable.combineLatest(
            discovered.startWith([]),
            peripheralWasRead.startWith([]),
            centralDidWrite.startWith([]),
            peripheralWasWrittenTo.startWith([])
        )

        debugEntries = combined
            .map { discovered, peripheralWasRead, centralDidWrite, peripheralWasWrittenTo in
                return generateItems(discovered: discovered, peripheralWasRead: peripheralWasRead,
                                     centralDidWrite: centralDidWrite, peripheralWasWrittenTo: peripheralWasWrittenTo)
            }
            .asDriver(onErrorJustReturn: [])
    }
}

enum DebugEntryViewData {
    case Header(String)
    case Item(String)
}

private func generateItems(discovered: [CEN], peripheralWasRead: [String], centralDidWrite: [String],
                           peripheralWasWrittenTo: [String]) -> [DebugEntryViewData] {

    return items(header: "Discovered", items: discovered.map{ $0.CEN })
        + items(header: "Peripheral was read", items: peripheralWasRead)
        + items(header: "Central did write", items: centralDidWrite)
        + items(header: "Peripheral was written to", items: peripheralWasWrittenTo)
}

private func items(header: String, items: [String]) -> [DebugEntryViewData] {
    [.Header(header)] + items.map{ .Item($0) }
}
