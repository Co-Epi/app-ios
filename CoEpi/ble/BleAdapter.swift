import Foundation
import TCNClient
import RxSwift

class BleAdapter {
    private let tcnService: TCNBluetoothService

    let discovered: ReplaySubject<Data> = .create(bufferSize: 1)
    let myTcn: ReplaySubject<String> = .create(bufferSize: 1)

    init(tcnGenerator: TcnGenerator) {

        var latestTcns = LimitedSizeQueue<Data>(maxSize: 500)

        tcnService = TCNBluetoothService(tcnGenerator: { [myTcn] in
            let tcnResult = tcnGenerator.generateTcn()
            log.d("Generated TCN: \(tcnResult)")

            return {
                switch tcnResult {
                case .success(let data):
                    myTcn.onNext(data.toHex())
                    return data
                case .failure(let error):
                    fatalError("Couldn't generate TCN: \(error)")
                }
            }()

        }, tcnFinder: { [discovered] (data, _) in
            // Temporary guard to filter repeated TCNs,
            // since we don't do anything meaningful with them in v0.3, and this overloads db/logs
            if !latestTcns.array.contains(data) {
                discovered.onNext(data)
                latestTcns.add(value: data)
            }
        }) { error in
            // TODO What kind of errors? Should we notify the user?
            log.e("TCN service error: \(error)")
        }

        tcnService.start()
    }
}
