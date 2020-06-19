import Alamofire
import Foundation

final class AlamofireLogger: EventMonitor {

    func requestDidResume(
        _ request: Request) {
        let body = request
            .request
            .flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"

        log.d("Request Started: \(request), body: \(body)")
    }

    func request<Value>(
        _ request: DataRequest,
        didParseResponse response: DataResponse<Value,
        Error>) {
        log.d("Request Received: \(request)")
    }

    func request(
        _ request: DataRequest,
        didParseResponse response: DataResponse<Data?, AFError>) {
        log.d("Request Received (unserialized):  \(response.debugDescription)")
    }

    func requestDidFinish(_ request: Request) {
        log.d("Request did finish: \(request.response.debugDescription)")
    }
}
