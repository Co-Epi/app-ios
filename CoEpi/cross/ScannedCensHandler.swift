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
        let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
        bleAdapter.discovered
            //use 'data' (tcn value) as grouping key (http://reactivex.io/documentation/operators/groupby.html, https://github.com/ReactiveX/RxSwift/blob/master/RxSwift/Observables/GroupBy.swift)
            .groupBy(keySelector: { data, distance in data })
            .subscribe { event in
                switch event {
                case .next(let group):
                    group
                        //take one sample per tcn value every 5 sec
                        .throttle(.milliseconds(5000), latest: false, scheduler: backgroundScheduler)
                        .subscribe { innerEvent in
                            switch innerEvent {
                            case .next(let dataDistanceTuple):
//                                    print("data: \(dataDistanceTuple.0.toHex()), distance: \(dataDistanceTuple.1)")
                                let tcnRecordingResult = self.tcnsRecorder.recordTcn(tcn: dataDistanceTuple.0, distance: dataDistanceTuple.1)
                                if !tcnRecordingResult.isSuccess() {
                                    log.e("Error recording TCN: \(tcnRecordingResult)")
                                }
                            case .error(let error):
                                log.e("Error in grouped tcn observer: \(error.localizedDescription)")
                            case .completed:
                                log.d("Inner observable completed")
                            }
                        }
                        .disposed(by: self.disposeBag)
                case .error(let error):
                    log.e("Error in central cen observer: \(error.localizedDescription)")
                case .completed:
                    log.d("Outer observable completed")
                }
            }
            .disposed(by: disposeBag)

    }
}
