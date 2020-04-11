import Foundation
import RxSwift
import Alamofire
import os.log

protocol CoEpiApi {

    func postCenReport(myCenReport: MyCenReport) -> Completable

    func getCenKeys() -> Single<[String]>

    func getCenReports(cenKey: CENKey) -> Single<[ApiCenReport]>
}

class CoEpiApiImpl: CoEpiApi {

//    private let baseUrl = "https://q69c4m2myb.execute-api.us-west-2.amazonaws.com/v3/"
    private let baseUrl = "https://v1.api.coepi.org/"

    func postCenReport(myCenReport: MyCenReport) -> Completable {
        os_log("Sending CEN report to API: %@", log: servicesLog, type: .debug, "\(myCenReport)")

        return post(url: baseUrl + "cenreport", params: ApiParamsCenReport(report: myCenReport))
    }

    func getCenKeys() -> Single<[String]> {
        get(url: baseUrl + "cenkeys")
    }

    func getCenReports(cenKey: CENKey) -> Single<[ApiCenReport]> {
        get(url: baseUrl + "cenreport/" + cenKey.cenKey)
    }

    private func get<T: Decodable>(url: String) -> Single<T> {
        Single.create { emitter -> Disposable in
            let request = AF.request(url).responseJSON { response in
                if let apiError = response.apiError {
                    emitter(.error(apiError))
                } else {
                    guard let data = response.data else {
                        emitter(.error(ApiError.error(message: "Response didn't have data")))
                        return
                    }
                    emitter(processGetResultData(data: data))
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }

    private func post<T: Encodable>(url: String, params: T) -> Completable {
        Single<Void>.create { emitter -> Disposable in
            let request = AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default)
                .response { response in
                    if let apiError = response.apiError {
                        emitter(.error(apiError))
                    } else {
                        emitter(.success(()))
                    }
                }
            return Disposables.create {
                request.cancel()
            }
        }.asObservable().ignoreElements()
    }
}

public enum ApiError: Error {
    case error(message: String)
}

// TODO better error handling. Ideally map all possible status codes and other errors (timeout etc) to an enum
private extension AFDataResponse {
    var apiError: ApiError? {
        if let error = error {
            return .error(message: error.localizedDescription)
        } else {
            if let statusCode = response?.statusCode {
                if (200..<400).contains(statusCode) {
                    return nil
                } else {
                    let dataStr: String = data.flatMap { String(data: $0, encoding: String.Encoding.utf8) } ?? "None"
                    return .error(message: "Http status: \(statusCode), data: \(dataStr)")
                }
            } else {
                os_log("Data response without response. Ignoring. %@", log: servicesLog, type: .debug, "\(self)")
                return nil
            }
        }
    }
}

private func processGetResultData<T: Decodable>(data: Data) -> SingleEvent<T> {
    do {
        let decoder = JSONDecoder()
        let obj = try decoder.decode(T.self, from: data)
        return .success(obj)
    } catch let error {
        return .error(ApiError.error(message: "Couldn't parse reponse: \(error), " +
            "data: \(String(describing: String(data: data, encoding: .utf8)))"))
    }
}
