import Foundation

/**
 * Represents the state of a long running operation
 * Can be used by UI to show progress indicator and success / error notifications
 */
enum OperationState<T> {
    case notStarted
    case progress
    case success(data: T)
    case failure(error: Error)

    func map<U>(f: (T) -> U) -> OperationState<U> {
        switch self {
        case .notStarted: return .notStarted
        case .success(let data): return .success(data: f(data))
        case .progress: return .progress
        case .failure(let error): return .failure(error: error)
        }
    }

    func flatMap<U>(f: (T) -> OperationState<U>) -> OperationState<U> {
        switch self {
        case .notStarted: return .notStarted
        case .success(let data): return f(data)
        case .progress: return .progress
        case .failure(let error): return .failure(error: error)
        }
    }
}

extension OperationState: Equatable where T: Equatable {

    static func == (lhs: OperationState, rhs: OperationState) -> Bool {
        switch (lhs, rhs) {
        case (let .success(data1), let .success(data2)):
            return data1 == data2
        case (let .failure(error1), let .failure(error2)):
            return error1.localizedDescription == error2.localizedDescription
        case (.notStarted, .notStarted):
            return true
        case (.progress, .progress):
            return true
        default: return false
        }
    }
}

typealias VoidOperationState = OperationState<()>

extension OperationState {

    func isComplete() -> Bool {
        switch self {
        case .success, .failure: return true
        case .notStarted, .progress: return false
        }
    }

    func isProgress() -> Bool {
        switch self {
        case .progress: return true
        case .notStarted, .success, .failure: return false
        }
    }
}
