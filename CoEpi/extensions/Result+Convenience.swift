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
        case .success(let success): return success
        case .failure(let err):
            let message = message.map { "\($0) " } ?? ""
            fatalError(message + err.localizedDescription)
        }
    }
}
