extension Result {
    func isSuccess() -> Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }

    func isFailure() -> Bool {
        !isSuccess()
    }

    @discardableResult
    func expect(_ message: String? = nil) -> Success {
        switch self {
        case let .success(success): return success
        case let .failure(err):
            let message = message.map { "\($0) " } ?? ""
            fatalError(message + err.localizedDescription)
        }
    }
}
