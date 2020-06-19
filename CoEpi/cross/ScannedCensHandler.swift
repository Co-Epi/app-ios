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
            .distinctUntilChanged()

            .subscribe(onNext: { [tcnsRecorder] data in
                log.d("Observed CEN: \(data.toHex())")

                let res = tcnsRecorder.recordTcn(tcn: data)

                if !res.isSuccess() {
                    log.e("Error recording TCN: \(res)")
                }

            }, onError: { error in
                log.e("Error in central cen observer: \(error.localizedDescription)")
            }).disposed(by: disposeBag)
    }

}
