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
        bleAdapter.discovered.subscribe(onNext: { [coepiRepo] cen in
            os_log("Storing CEN: %@", log: bleCentralLog, "\(cen)")
            coepiRepo.storeObservedCen(cen: cen)
        }, onError: { error in
            os_log("Error in central cen observer: %@", log: bleCentralLog, error.localizedDescription)
        }).disposed(by: disposeBag)
    }
}
