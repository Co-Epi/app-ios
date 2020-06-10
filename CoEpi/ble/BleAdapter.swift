import Foundation
import TCNClient
import RxSwift

class BleAdapter {
    private let tcnService: TCNBluetoothService

    let discovered: ReplaySubject<Data> = .create(bufferSize: 1)
    let myTcn: ReplaySubject<String> = .create(bufferSize: 1)

    init(tcnGenerator: TcnGenerator) {
        // Temporary guard to filter repeated TCNs,
        // since we don't do anything meaningful with them in v0.3, and this overloads db/logs
        var lastObserverdTcns = LimitedSizeQueue<Data>(maxSize: 500)

        // Sometimes the device appears to observe its own TCN
        // This is a quick fix to alleviate this
        // (It does not handle multiple devices reading simultaneously, in which case the device still could
        // observe its own TCN)
        // TODO investigate why it happens.
        var lastGeneratedTcn: Data?

        tcnService = TCNBluetoothService(tcnGenerator: { [myTcn] in
            let tcnResult = tcnGenerator.generateTcn()
            log.d("Generated TCN: \(tcnResult)")

            return {
                switch tcnResult {
                case .success(let data):
                    myTcn.onNext(data.toHex())
                    lastGeneratedTcn = data
                    return data
                case .failure(let error):
                    fatalError("Couldn't generate TCN: \(error)")
                }
            }()

        }, tcnFinder: { [discovered] (data, _) in
            if !lastObserverdTcns.array.contains(data) && lastGeneratedTcn != data {
                discovered.onNext(data)
                lastObserverdTcns.add(value: data)
            }
        }) { error in
            // TODO What kind of errors? Should we notify the user?
            log.e("TCN service error: \(error)")
        }

        tcnService.start()
    }
}
