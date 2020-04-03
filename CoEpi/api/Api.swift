import Foundation
import RxSwift
import RxSwift
import RxAlamofire
import RxBlocking

protocol Api {

    func postCenReport(cenReport: MyCenReport) -> Completable

    func getCenKeys() -> Single<[String]>

    func getCenReports(cenKey: CENKey) -> Single<[ReceivedCenReport]>
}

// TODO error handling

class ApiImpl: Api {

    func postCenReport(cenReport: MyCenReport) -> Completable {
        struct reportPayload: Encodable {
            let reportID: String
            let report: String
            let cenKeys: String
            let reportTimestamp: Int64
        }

        let payload: reportPayload = reportPayload(reportID: cenReport.report.id,
                                                   report: cenReport.report.report,
                                                   cenKeys: cenReport.keys,
                                                   reportTimestamp: cenReport.report.timestamp)

        guard let jsonData = try? JSONEncoder().encode(payload) else {
            return Completable.empty()
        }

        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        }

        let stringURL = "https://coepi.wolk.com:8080/cenreport"
        var request = URLRequest(url: URL(string: stringURL)!)
        request.httpBody = jsonData
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return RxAlamofire.request(request).debug().responseString().debug().ignoreElements()
    }

    func getCenKeys() -> Single<[String]> {
        let stringURL = "https://coepi.wolk.com:8080/cenkeys"
        return json(.get, stringURL).asSingle().map { result in
            result as! [String]
        }
    }

    func getCenReports(cenKey: CENKey) -> Single<[ReceivedCenReport]> {
        let stringURL = "https://coepi.wolk.com:8080/cenreport/\(cenKey.cenKey)"
        return RxAlamofire.requestJSON(.get, stringURL).debug().asSingle().map { (r, json) in
            let jsonArray = json as! [[String: AnyObject]]
            return jsonArray.map {
                let id = $0["reportID"] as! String
                let report = $0["report"] as! String
                let timestamp = $0["reportTimeStamp"] as! Int64
                return ReceivedCenReport(report: CenReport(id: id, report: report, timestamp: timestamp))
            }
        }
    }
}
