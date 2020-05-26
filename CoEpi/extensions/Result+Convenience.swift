extension Result {

    func isSuccess() -> Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }

    func expect() {
        switch self {
        case .success: break
        case .failure(let err): fatalError(err.localizedDescription)
        }
    }
}
