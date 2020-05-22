import Foundation
import os.log
import RxSwift

class ScannedCensHandler {
    private let cenRepo: CENRepo
    private let bleAdapter: BleAdapter

    private let disposeBag = DisposeBag()

    init(cenRepo: CENRepo, bleAdapter: BleAdapter) {
        self.cenRepo = cenRepo
        self.bleAdapter = bleAdapter

        forwardScannedCensToCoEpiRepo()
    }

    private func forwardScannedCensToCoEpiRepo() {
        bleAdapter.discovered
            .distinctUntilChanged()

            .subscribe(onNext: { [cenRepo] data in
                let cen = CEN(CEN: data.toHex(), timestamp: .now())
                os_log("Observed CEN: %{public}@", log: bleLog, "\(cen)")

                if !(cenRepo.insert(cen: cen)) {
                    os_log("Stored new CEN in DB: %{public}@", log: bleLog, type: .debug, "\(cen)")
                } else {
                    os_log("CEN was already in DB: %{public}@", log: bleLog, type: .debug, "\(cen)")
                }

            }, onError: { error in
                os_log("Error in central cen observer: %{public}@", log: bleLog, error.localizedDescription)
            }).disposed(by: disposeBag)
    }

}
