import Foundation
import os.log
import RxSwift

class ScannedCensHandler {
    private let bleAdapter: BleAdapter
    private let tcnsRecorder: ObservedTcnsRecorder

    private let disposeBag = DisposeBag()

    init(bleAdapter: BleAdapter, tcnsRecorder: ObservedTcnsRecorder) {
        self.bleAdapter = bleAdapter
        self.tcnsRecorder = tcnsRecorder

        forwardScannedCensToCoEpiRepo()
    }

    private func forwardScannedCensToCoEpiRepo() {
        bleAdapter.discovered
            .distinctUntilChanged()

            .subscribe(onNext: { [tcnsRecorder] data in
                os_log("Observed CEN: %{public}@", log: bleLog, "\(data.toHex())")

                let res = tcnsRecorder.recordTcn(tcn: data)

                if (!res.isSuccess()) {
                    os_log("Error recording TCN: %{public}@", log: bleLog, type: .debug, "\(res)")
                }

            }, onError: { error in
                os_log("Error in central cen observer: %{public}@", log: bleLog, error.localizedDescription)
            }).disposed(by: disposeBag)
    }

}
