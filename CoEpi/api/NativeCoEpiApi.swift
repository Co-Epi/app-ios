import Foundation
import RxSwift
import Alamofire
import os.log
import UIKit

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Generic code to decode Rust library results. Not only for API calls.
// TODO move somewhere else.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

struct LibResult<T: Decodable>: Decodable {
    let status: Int
    let data: T?
    let error_message: String?

    func isSuccess() -> Bool {
        (200...299).contains(status)
    }
}

// TODO better way to decode LibResult when it doesn't have data. Maybe don't use Decodable.
private typealias ArbitraryType = String

private extension LibResult {

    func toResult() -> Result<T, ApiError> {
        if isSuccess() {
            if let data = data {
                return .success(data)
            } else {
                return .failure(.error(message: "Unexpected: Library result success but no data: \(self)"))
            }
        } else {
            return .failure(.error(message: "Lib error result: \(self)"))
        }
    }

    func toVoidResult() -> Result<(), ApiError> {
        if isSuccess() {
            return .success(())
        } else {
            return .failure(.error(message: "Lib error result: \(self)"))
        }
    }
}

private func toLibResult<T>(rawResult: Unmanaged<CFString>?) -> LibResult<T> {
    // TODO handle force unwrap, probably we need to return Result<LibResult<T>, Error>>
    let resultValue: CFString = rawResult!.takeRetainedValue()
    let resultString = resultValue as String

    let data = resultString.data(using: .utf8)!
    let decoder = JSONDecoder()
    return try! decoder.decode(LibResult<T>.self, from: data)
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Synchronous API
// Currently called from RX calls. In actual implementation these should be exposed directly.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

private func postCenReportSync(myCenReport: MyCenReport) -> Result<(), ApiError> {
    let libResult: LibResult<ArbitraryType> = toLibResult(rawResult: post_report(myCenReport.report.report))
    return libResult.toVoidResult()
}

private func getCenReportsSync(cenKey: CENKey) -> Result<[String], ApiError> {
    let libResult: LibResult<[String]> = toLibResult(rawResult: get_reports(0, 21600))
    return libResult.toResult()
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


class NativeCoEpiApi: CoEpiApi {

    func postCenReport(myCenReport: MyCenReport) -> Completable {
        return Completable.create { emitter -> Disposable in
            switch postCenReportSync(myCenReport: myCenReport) {
            case .success(_): emitter(.completed)
            case .failure(let error): emitter(.error(error))
            }
            return Disposables.create {}
        }
    }

    func getCenReports(cenKey: CENKey) -> Single<[ApiCenReport]> {
        Single.create { emitter -> Disposable in
            switch getCenReportsSync(cenKey: cenKey) {
            case .success(let reportStrings):
                let reports: [ApiCenReport] = reportStrings.map {
                    ApiCenReport(reportID: UUID().uuidString, report: $0, reportTimeStamp: UnixTime.now().value)
                }
                emitter(.success(reports))
            case .failure(let error): emitter(.error(error))
            }
            return Disposables.create {}
        }
    }

    func getCenKeys() -> Single<[String]> {
        // Does nothing
        Single.create { emitter -> Disposable in
            emitter(.success([]))
            return Disposables.create {}
        }
    }
}
