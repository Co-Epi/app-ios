import Alamofire
import os.log
import Foundation

final class AlamofireLogger: EventMonitor {

    func requestDidResume(_ request: Request) {
        let body = request.request.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
        os_log("Request Started: %{public}@, body: %{public}@", log: networkingLog, type: .debug, "\(request)",
            "\(body)")
    }

    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, Error>) {
        os_log("Response Received: %{public}@", log: networkingLog, type: .debug, "\(request)")
    }

    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        os_log("Response Received (unserialized): %{public}@", log: networkingLog, type: .debug,
               response.debugDescription)
    }

    func requestDidFinish(_ request: Request) {
        os_log("Request did finish: %{public}@", log: networkingLog, type: .debug,
               request.response.debugDescription)
    }
}
