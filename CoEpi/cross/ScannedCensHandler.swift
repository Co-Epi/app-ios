import Foundation
import os.log
import RxSwift

class ScannedCensHandler {
    private let coepiRepo: CoEpiRepo
    private let bleCentral: CentralReactive

    private let disposeBag = DisposeBag()

    init(coepiRepo: CoEpiRepo, bleCentral: CentralReactive) {
        self.coepiRepo = coepiRepo
        self.bleCentral = bleCentral

        forwardScannedCensToCoEpiRepo()
    }

    private func forwardScannedCensToCoEpiRepo() {
        bleCentral.centralContactReceived.map {
            $0.toReceivedCen()
        }.subscribe(onNext: { [coepiRepo] cen in
            coepiRepo.storeObservedCen(cen: cen)
        }, onError: { error in
            os_log("Error in central cen observer: %@", log: bleCentralLog, error.localizedDescription)
        }).disposed(by: disposeBag)
    }
}

private extension BTContact {
    func toReceivedCen() -> CEN {
        CEN(CEN: theirIdentifier, timestamp: Int64(Date().timeIntervalSince1970))
    }
}
