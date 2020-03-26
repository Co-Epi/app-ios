import RxSwift
import RxCocoa

protocol DebugViewModel {
    var debugEntries: Driver<[DebugEntryViewData]> { get }
}

class DebugViewModelImpl: DebugViewModel {

    let debugEntries: Driver<[DebugEntryViewData]>

    init(peripheral: Peripheral, central: Central) {

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

            peripheral.peripheralContactSent
                .map { Optional($0) }
                .startWith(nil),

            receivedContacts
                .startWith([]),

            discovered
                .startWith([])
        )

        debugEntries = combined
            .map { peripheralState, peripheralContactSent, receivedContacts, discovered in
                let peripheralState = peripheralState ?? ""
                let peripheralContactSent = peripheralContactSent?.identifier.uuidString ?? "None"
                return [
                    .Header("Peripheral state"),
                    .Item(peripheralState),
                    .Header("Contact sent"),
                    .Item(peripheralContactSent),
                    .Header("Received contacts")]
                    + receivedContacts.map{
                        .Item($0.identifier.uuidString)
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
