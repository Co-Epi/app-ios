import Foundation
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
            .subscribe(onNext: { [tcnsRecorder] data, distance in
                let res = tcnsRecorder.recordTcn(tcn: data, distance: distance)

                if !res.isSuccess() {
                    log.e("Error recording TCN: \(res)")
                }

            }, onError: { error in
                log.e("Error in central cen observer: \(error.localizedDescription)")
            }).disposed(by: disposeBag)
    }
}
