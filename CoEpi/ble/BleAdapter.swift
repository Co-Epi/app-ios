import Foundation
import RxSwift
import TCNClient

class BleAdapter {
    private let tcnService: TCNBluetoothService

    let discovered: ReplaySubject<(Data, Float)> = .create(bufferSize: 1)
    let myTcn: ReplaySubject<String> = .create(bufferSize: 1)

    init(tcnGenerator: TcnGenerator) {
        // Sometimes the device appears to observe its own TCN
        // This is a quick fix to alleviate this
        // (It does not handle multiple devices reading simultaneously, in which case the device still could
        // observe its own TCN)
        // TODO: investigate why it happens.
        var lastGeneratedTcn: Data?

        tcnService = TCNBluetoothService(tcnGenerator: { [myTcn] in
            let tcnResult = tcnGenerator.generateTcn()
            log.d("Generated TCN: \(tcnResult)")

            return {
                switch tcnResult {
                case let .success(data):
                    myTcn.onNext(data.toHex())
                    lastGeneratedTcn = data
                    return data
                case let .failure(error):
                    fatalError("Couldn't generate TCN: \(error)")
                }
            }()

        }, tcnFinder: { [discovered] data, distance in
            if lastGeneratedTcn != data {
                discovered.onNext((data, Float(distance ?? 0)))
            }
        }) { error in
            // TODO: What kind of errors? Should we notify the user?
            log.e("TCN service error: \(error)")
        }

        tcnService.start()
    }
}
