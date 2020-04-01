import Foundation
import RxSwift
import RxCocoa

class DebugViewModel {

    let debugEntries: Driver<[DebugEntryViewData]>

    init(peripheral: PeripheralReactive, central: CentralReactive) {

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
