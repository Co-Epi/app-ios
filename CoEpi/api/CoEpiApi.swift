import Foundation
import RxSwift
import Alamofire

protocol CoEpiApi {

    func postCenReport(cenReport: MyCenReport) -> Completable

    func getCenKeys() -> Single<[String]>

    func getCenReports(cenKey: CENKey) -> Single<[ApiCenReport]>
}

class CoEpiApiImpl: CoEpiApi {

    private let baseUrl = "https://coepi.wolk.com:8080/"

    func postCenReport(cenReport: MyCenReport) -> Completable {
        post(url: baseUrl + "cenreport", params: ApiParamsCenReport(report: cenReport))
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
                guard let data = response.data else { return }
                do {
                    let decoder = JSONDecoder()
                    let obj = try decoder.decode(T.self, from: data)
                    emitter(.success(obj))
                } catch let error {
                    emitter(.error(ApiError.error(
                        message: "Couldn't parse reponse: \(error), " +
                            "data: \(String(describing: String(data: data, encoding: .utf8)))")))
                }
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }

    func post<T: Encodable>(url: String, params: T) -> Completable {
        Single<Void>.create { emitter -> Disposable in
            let request = AF.request(url, method: .post, parameters: params, encoder: JSONParameterEncoder.default)
                .response { response in

                if let error = response.error {
                    emitter(.error(error))
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
