import Foundation
import RxSwift
import RxCocoa

class DebugViewModel {

    let debugEntries: Driver<[DebugEntryViewData]>

    init(peripheral: PeripheralReactive, central: CentralReactive, api: Api) {


        //TESTING NETWORK
        print ("Testing Networking at lines 14 - 21 in DebugViewModel.swift")
        api.getCenKeys()
            .subscribe { print($0) }
        
        api.getCenReport(cenKey: CENKey(cenKey: "17FA287EBE6B42A3859A60C12CF71394"))
            .subscribe { print($0) }

        api.postCenReport(cenReport: CENReport(id: "80d2910e783ab87837b444c224a31c9745afffaaacd4fb6eacf233b5f30e3140", report: "c2V2ZXJlIGZldmVyLGNvdWdoaW5nLGhhcmQgdG8gYnJlYXRoZQ==", timestamp: Int64(Date().timeIntervalSince1970)))
            .subscribe { print($0) }
        //TESTING NETWORK
         

        let receivedContacts = central
            .centralContactReceived
            .scan([]) { acc, element in acc + [element] }

        let discovered = central
            .discovery
            .scan([]) { acc, element in acc + [element] }

        let combined = Observable.combineLatest(
            peripheral
                .peripheralState
                .map { Optional($0) }
                .startWith(nil),

            peripheral.didReadCharacteristic
                .map { Optional($0) }
                .startWith(nil),

            receivedContacts
                .startWith([]),

            discovered
                .startWith([])
        )

        debugEntries = combined
            .map { peripheralState, didReadCharacteristic, receivedContacts, discovered in
                let peripheralState = peripheralState ?? ""
                let didReadCharacteristic: String = didReadCharacteristic?.ourIdentifier ?? "None"
                return [
                    .Header("Peripheral state"),
                    .Item(peripheralState),
                    .Header("Contact sent"),
                    .Item(didReadCharacteristic),
                    .Header("Received contacts")]
                    + receivedContacts.map{
                        .Item($0.theirIdentifier)
                    }
                    + [.Header("Discovered devices")]
                    + discovered.map{ .Item($0.debugIdentifier) }
            }
            .asDriver(onErrorJustReturn: [])
    }
}

private extension DetectedPeripheral {
    var debugIdentifier: String {
        (name.map { "\($0), " } ?? "") + uuid.uuidString
    }
}

enum DebugEntryViewData {
    case Header(String)
    case Item(String)
}
