import Foundation

protocol AlertsFetcher {
    func fetchNewAlerts() -> Result<[RawAlert], ApiError>
}

class NativeCore: AlertsFetcher {

    func fetchNewAlerts() -> Result<[RawAlert], ApiError> {
        guard let libResult: LibResult<[NativeAlert]> = fetch_new_reports()?.toLibResult() else {
            return .failure(ApiError.error(message: "Couldn't get library result"))
        }

        // TODO contact time instead of .now() (see Rust)
        // TODO id (see Rust)
        // TODO memo

        return libResult.toResult().map { nativeAlerts in
            nativeAlerts.map {
                RawAlert(id: $0.id, memoStr: $0.memo, contactTime: .now())
            }
        }
    }
}

// TODO Remove NativeAlert, use directly RawAlert for Rust mapping (after adding contact time in Rust)
private struct NativeAlert: Codable {
    let id: String
    let memo: String
}
