import Foundation
import RxSwift
import Alamofire
import os.log

// TODO remove this file
protocol CoEpiApi {
    func postCenReport(myCenReport: MyCenReport) -> Completable
}

public enum ApiError: Error {
    case error(message: String)
}

class NativeCoEpiApi: CoEpiApi {

    // TODO Send symptom inputs, not report. Move to NativeCore. No Rx.
    func postCenReport(myCenReport: MyCenReport) -> Completable {
        return Completable.create { emitter -> Disposable in
            switch postCenReportSync(myCenReport: myCenReport) {
            case .success(_): emitter(.completed)
            case .failure(let error): emitter(.error(error))
            }
            return Disposables.create {}
        }
    }
}

private func postCenReportSync(myCenReport: MyCenReport) -> Result<(), ApiError> {
    guard let libResult: LibResult<ArbitraryType> = post_report(myCenReport.report.report)?.toLibResult() else {
        return .failure(ApiError.error(message: "Couldn't get library result"))
    }
    return libResult.toVoidResult()
}
