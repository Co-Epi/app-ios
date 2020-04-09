import Foundation
import RxSwift

/// Bridges between app and covidwatch BLE lib
class BleAdapter {

    let discovered: ReplaySubject<CEN> = .create(bufferSize: 1)

    // Debugging
    let myCen: ReplaySubject<String> = .create(bufferSize: 1)
    let peripheralWasRead: ReplaySubject<String> = .create(bufferSize: 1)
    let centralDidWrite: ReplaySubject<String> = .create(bufferSize: 1)
    let peripheralWasWrittenTo: ReplaySubject<String> = .create(bufferSize: 1)

    private let cenReadHandler: ContactReceivedHandler

    init(cenReadHandler: ContactReceivedHandler) {
        self.cenReadHandler = cenReadHandler
    }

    func provideMyCen() -> Data {
        let cen = cenReadHandler.provideMyCen()
        myCen.onNext(cen.toHex())
        return cen
    }

    func didDiscoverCen(cen: Data) {
        // maybe create ReceivedCen type like in Android.
        discovered.onNext(CEN(CEN: cen.toHex(), timestamp: Date().coEpiTimestamp))
    }

    func peripheralWasRead(cen: Data) {
        peripheralWasRead.onNext(cen.toHex())
    }

    func peripheralWasWrittenTo(cen: Data) {
        peripheralWasWrittenTo.onNext(cen.toHex())
    }

    func centralDidWrite(cen: Data) {
        centralDidWrite.onNext(cen.toHex())
    }
}
