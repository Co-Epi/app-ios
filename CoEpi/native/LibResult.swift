import Foundation
import os.log

struct LibResult<T: Decodable>: Decodable {
    let status: Int
    let data: T?
    let error_message: String?

    func isSuccess() -> Bool {
        (200...299).contains(status)
    }
}

// TODO better way to decode LibResult when it doesn't have data. Maybe don't use Decodable.
typealias ArbitraryType = String

extension LibResult {

    func toResult() -> Result<T, CoreError> {
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

    func toVoidResult() -> Result<(), CoreError> {
        if isSuccess() {
            return .success(())
        } else {
            return .failure(.error(message: "Lib error result: \(self)"))
        }
    }
}

extension Unmanaged where Instance == CFString {

    func toLibResult<T>() -> LibResult<T> {
        let resultValue: CFString = takeRetainedValue()
        let resultString = resultValue as String

        os_log("Deserializing native core result: %{public}@, body: %{public}@", log: servicesLog,
               type: .debug, "\(resultString)")

        // TODO review safety of utf-8 force unwrap
        let data = resultString.data(using: .utf8)!
        let decoder = JSONDecoder()

        do {
            return try decoder.decode(LibResult<T>.self, from: data)
        } catch let e {
            // Bad gateway (502): "The server, while acting as a gateway or proxy, received an invalid response from the upstream server"
            // Using HTTP status codes for library communication probably temporary. For now it seems suitable.
            return LibResult(status: 502, data: nil, error_message: "Invalid library result: \(e)")
        }
    }
}

public enum CoreError: Error {
    case error(message: String)
}
