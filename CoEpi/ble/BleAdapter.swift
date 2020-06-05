import Foundation
import TCNClient
import RxSwift
import os.log

class BleAdapter {
    private let tcnService: TCNBluetoothService

    let discovered: ReplaySubject<Data> = .create(bufferSize: 1)
    let myTcn: ReplaySubject<String> = .create(bufferSize: 1)

    init(tcnGenerator: TcnGenerator) {
        tcnService = TCNBluetoothService(tcnGenerator: { [myTcn] in
            let tcnResult = tcnGenerator.generateTcn()
            os_log("Generated TCN: %{public}@", type: .error, "\(tcnResult)")

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
            discovered.onNext(data)
        }) { error in
            // TODO What kind of errors? Should we notify the user?
            os_log("TCN service error: %{public}@", type: .error, "\(error)")
        }

        tcnService.start()
    }
}
