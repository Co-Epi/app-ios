import Foundation
import os.log
import RxSwift

class ScannedCensHandler {
    private let coepiRepo: CoEpiRepo
    private let bleAdapter: BleAdapter

    private let disposeBag = DisposeBag()

    init(coepiRepo: CoEpiRepo, bleAdapter: BleAdapter) {
        self.coepiRepo = coepiRepo
        self.bleAdapter = bleAdapter

        forwardScannedCensToCoEpiRepo()
    }

    private func forwardScannedCensToCoEpiRepo() {
        bleAdapter.discovered
            .distinctUntilChanged()
            .subscribe(onNext: { [coepiRepo] data in
                let cen = CEN(CEN: data.toHex(), timestamp: .now())
                os_log("Observed CEN: %{public}@", log: bleLog, "\(cen)")
                coepiRepo.storeObservedCen(cen: cen)
            }, onError: { error in
                os_log("Error in central cen observer: %{public}@", log: bleLog, error.localizedDescription)
            }).disposed(by: disposeBag)
    }
}
