import Foundation
import RxSwift

protocol Api {

    func postCenReport(cenReport: CENReport) -> Completable

    func getCenKeys() -> Single<[String]>

    func getCenReport(cenKey: CENKey) -> Single<CENReport>
}

// TODO actual api
class ApiImpl: Api {

    func postCenReport(cenReport: CENReport) -> Completable {
        Completable.empty()
    }

    func getCenKeys() -> Single<[String]> {
        Single.just(["key1", "key2"])
    }

    func getCenReport(cenKey: CENKey) -> Single<CENReport> {
        Single.just(CENReport(id: "1", report: "report1", timestamp: Int64(Date().timeIntervalSince1970)))
    }
}
