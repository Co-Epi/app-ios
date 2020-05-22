import Foundation

protocol AlertsFetcher {
    func fetchNewAlerts() -> Result<[RawAlert], ServicesError>
}

protocol SymptomsReporter {
    // TODO Send symptom inputs, not report
    func postCenReport(myCenReport: MyCenReport) -> Result<(), ServicesError>
}

class NativeCore: AlertsFetcher, SymptomsReporter {

    func fetchNewAlerts() -> Result<[RawAlert], ServicesError> {
        guard let libResult: LibResult<[NativeAlert]> = fetch_new_reports()?.toLibResult() else {
            return libraryFailure()
        }

        // TODO contact time instead of .now() (see Rust)
        // TODO id (see Rust)
        // TODO memo

        return libResult.toResult().mapErrorToServicesError().map { nativeAlerts in
            nativeAlerts.map {
                RawAlert(id: $0.id, memoStr: $0.memo, contactTime: .now())
            }
        }
    }

    func postCenReport(myCenReport: MyCenReport) -> Result<(), ServicesError> {
        guard let libResult: LibResult<ArbitraryType> = post_report(myCenReport.report.report)?.toLibResult() else {
            return libraryFailure()
        }
        return libResult.toVoidResult().mapErrorToServicesError()
    }

    private func libraryFailure<T>() -> Result<T, ServicesError> {
        .failure(.error(message: "Couldn't get library result"))
    }
}

// TODO Remove NativeAlert, use directly RawAlert for Rust mapping (after adding contact time in Rust)
private struct NativeAlert: Codable {
    let id: String
    let memo: String
}

extension Result where Failure == CoreError {
    func mapErrorToServicesError() -> Result<Success, ServicesError> {
        mapError {
            switch $0 {
            case .error(let message): return .error(message: message)
            }
        }
    }
}

public enum ServicesError: Error {
    case error(message: String)
}
