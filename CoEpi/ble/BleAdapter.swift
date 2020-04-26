import Foundation
import TCNClient
import RxSwift
import os.log

class BleAdapter {
    private let cenReadHandler: ContactReceivedHandler

    private let tcnService: TCNBluetoothService

    let discovered: ReplaySubject<CEN> = .create(bufferSize: 1)
    let myCen: ReplaySubject<String> = .create(bufferSize: 1)

    init(cenReadHandler: ContactReceivedHandler) {
        self.cenReadHandler = cenReadHandler

        tcnService = TCNBluetoothService(tcnGenerator: { [myCen] in
            let cen = cenReadHandler.provideMyCen()
            myCen.onNext(cen.toHex())
            return cen

        }, tcnFinder: { [discovered] (data, _) in
            discovered.onNext(CEN(CEN: data.toHex(), timestamp: .now()))
        }) { error in
            // TODO What kind of errors? Should we notify the user?
            os_log("TCN service error: %{public}@", type: .error, "\(error)")
        }

        tcnService.start()
    }
}
