import XCTest
import Foundation
import Alamofire
import TCNClient
import CryptoKit

final class AlamofireLogger: EventMonitor {
    func requestDidResume(_ request: Request) {
        let body = request.request.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
        let message = """
        ⚡️ Request Started: \(request)
        ⚡️ Body Data: \(body)
        """
        NSLog(message)
    }
    
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, Error>) {
        NSLog("⚡️ Response Received: \(response.debugDescription)")
    }
    
    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        NSLog("⚡️ Response Received (unserialized): \(response.debugDescription)")
    }
    
    func requestDidFinish(_ request: Request){
        NSLog("⚡️ Request did finish: \(request.response.debugDescription)")
    }
}

enum BackendType{
    case aws
    case aws_updated_interval_format
    case golang
}

struct BackendConfig{
    let type: BackendType
    let url: String
    let intervalLength : Int64
    let intervalLengthParam : String
    let dateParam : String?
}


func configureBackend(_ type: BackendType = .aws) -> BackendConfig{
    switch type {
    case .golang:
        return BackendConfig(
            type: .golang,
            url: "https://v1.api.coepi.org/tcnreport/v0.4.0",
            intervalLength: 86400,
            intervalLengthParam: "intervalLength",
            dateParam: nil)
        
    case .aws_updated_interval_format:
    //curl -X GET "https://zmqh8rwdx4.execute-api.us-west-2.amazonaws.com/v4/tcnreport/0.4.0?intervalNumber=73581&intervalLength=21600"
        return BackendConfig(type: .aws_updated_interval_format,
             url: "https://zmqh8rwdx4.execute-api.us-west-2.amazonaws.com/v4/tcnreport/0.4.0",
             intervalLength: 21600,
             intervalLengthParam: "intervalLength",
             dateParam: nil)
    
    default:
        return BackendConfig(
            type: .aws,
            url: "https://18ye1iivg6.execute-api.us-west-1.amazonaws.com/v4/tcnreport",
            intervalLength: 6 * 3600,
            intervalLengthParam: "intervalLengthMs",
            dateParam: "date")
    }
}

class CoEpiNetworkingV4Tests: XCTestCase {
    
    let backend = configureBackend(.aws_updated_interval_format)
    
    func testV4GetTcnReport() {
        /*
         curl -X GET https://18ye1iivg6.execute-api.us-west-1.amazonaws.com/v4/tcnreport
         ["WlhsS01GcFlUakJKYW05cFdXMDVhMlZUU2prPQ=="]
         */
        let url: String = backend.url //+ "/tcnreport"
        executeGet(url: url)
    }
    
    
    func testV4GetTcnReportWithDate() {
        /**
         curl -X GET https://18ye1iivg6.execute-api.us-west-1.amazonaws.com/v4/tcnreport?date=2020-04-19
         */
        let dateString = "2020-05-17"
        guard let date = getDateForString(dateString) else
        {
            XCTFail("Date conversion failed for [\(dateString)]")
            return
        }
        
        getTcnForDate(date)
    }
    
    func testV4GetTcnReportWithIntervalNumber() {
        /**
         GET /tcnreport?date={report_date}?intervalNumber={interval}?intervalLengthMs={interval_length_ms}
         */
        
        /**
         formatedDate : [2020-04-20 01:28:04 +0200]
         formatedUtcDate : [2020-04-19 23:28:04 +0000]
         */
        let currentDate = Date()
        
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        let startOfDay = cal.startOfDay(for: currentDate)
        NSLog("⚡️ \(startOfDay.description)")
        getTcnForDate(startOfDay)
    }
    
    
    func postTcnReportHelper(urlRequest : URLRequest) {
        /**
         curl -X POST https://18ye1iivg6.execute-api.us-west-1.amazonaws.com/v4/tcnreport -d "ZXlKMFpYTjBJam9pWW05a2VTSjk="
         */
        
        let expect = expectation(description: "POST request complete")
        
        //Fix for error message: "CredStore - performQuery - Error copying matching creds.  Error=-25300" See: https://stackoverflow.com/a/54100650
        let configuration = URLSessionConfiguration.default
        configuration.urlCredentialStorage = nil
        
        let session = Session(configuration:configuration, eventMonitors: [ AlamofireLogger() ])
        
        do {
            let _ = session.request(urlRequest).validate()
                .cURLDescription { description in
                    NSLog(description)
            }
            .response { response in
                if let status = response.response?.statusCode {
                    if status >= 300 {
                        XCTFail("Bad status: \(status)")
                    }
                    
                }
                switch response.result {
                case .success:
                    expect.fulfill()
                case .failure(let error):
                    NSLog("\n\n⚡️ Request failed with error: \(error)")
                    XCTFail()
                }
                
            }
        }
        
        waitForExpectations(timeout: 15)
    }
    
    
    func testTcnClientCrypto(){
        
        do {
            let rak =  ReportAuthorizationKey(reportAuthorizationPrivateKey: .init())
            var tck = rak.initialTemporaryContactKey
            var tcNumbers = [TemporaryContactNumber]()
            
            for _ in 0..<100{
                tcNumbers.append(tck.temporaryContactNumber)
                tck = tck.ratchet()!
            }
            
            let signedReport = try rak.createSignedReport(
                memoType: .CoEpiV1,
                memoData: "symptom data".data(using: .utf8)!,
                startIndex: 20,
                endIndex: 90)
            
            // Verify the source integrity of the report...
            XCTAssertTrue(try signedReport.verify())
            
            // ...allowing the disclosed TCNs to be recomputed.
            let recomputedTemporaryContactNumbers = signedReport.report.getTemporaryContactNumbers()
            
            // Check that the recomputed TCNs match the originals.
            // The slice is offset by 1 because tcn_0 is not included.
            XCTAssertEqual(
                recomputedTemporaryContactNumbers,
                Array(tcNumbers[(20 - 1)..<(90 - 1)])
            )
        }catch{
            XCTFail(error.localizedDescription)
        }
    }
    
    
    
    func testReportInflation(){
        //        let hexEncodedSignedReport = "fd8deb9d91a13e144ca5b0ce14e289532e040fe0bf922c6e3dadb1e4e2333c78df535b90ac99bec8be3a8add45ce77897b1e7cb1906b5cff1097d3cb142fd9d002000a00001973796d70746f6d2064617461205b313538393034323531385d5ff71f09e77001dedcd0d0516a8c11d8d29f6c283400fd13d5c13bea08002381d6e1e930cbbd5d41f98bb62902fa14854f4e16f874aca5c1dedaf43225879008"
        
        //        let hexEncodedSignedReport = "fd8deb9d91a13e144ca5b0ce14e289532e040fe0bf922c6e3dadb1e4e2333c78b86907c5bc76452bc57c8aac263f2003310f41d7b6d761ad833fb0c50ac96dedf401f901001973796d70746f6d2064617461205b313538393134353139365d2a3528b3c1d0945a58856b2845679f2372d48e9f1ed2e38042f23fbf37072833022b6b07186a1b1dfa2819a93675a53e9bad5c79a3c1ef0f5f08b3080bac6e0f"
        
        let hexEncodedSignedReport = "O3NjFJFeY/YdaWqNZoZYT+K54DAiiZJNrR3OUzfwLwkQMJOhvKPus4P4VFutzHKOVoqrUU09EGTISM7VJJQULgEAAQAACwEA5se6XgAAAAAEtI3zGVfTKgfRbUPDfaosvhaKnYW0yLw90syDF3wUBj8eVWcbe43zL+/sQewXc+5+okOQqie489E9LeHt1gOKBQ=="
        
        
        do {
            let signedReport = try SignedReport(serializedData: Data(base64Encoded: hexEncodedSignedReport)!)
            do {
                let verified = try signedReport.verify()
                print("verified = \(verified)")
                
                let n1 = signedReport.report.startIndex
                let n2 = signedReport.report.endIndex
                let memoData = signedReport.report.memoData
                
                
                print("start = \(n1)")
                print("end = \(n2)")
                print("memoData = \(memoData)")
                if let memo : String = String(data:memoData, encoding: .utf8){
                    print("memo = \(memo)")
                }else{
                    print("Problem with memo")
                }
                
            }
            catch {
                XCTFail("Verification failed : " + error.localizedDescription)
            }
            
            
        }catch{
            XCTFail("SignedReportInit failed : " + error.localizedDescription)
        }
        
        
    }
    
    
    //Based on TCNClientCryptoTests:testTestVectors
    func testTcnClientCryptoNetworking(){
        do {
            let expected_rak_bytes = "577cfdae21fee71579211ab02c418ee0948bacab613cf69d0a4a5ae5a1557dbb"
            let expected_rvk_bytes = "fd8deb9d91a13e144ca5b0ce14e289532e040fe0bf922c6e3dadb1e4e2333c78"
            let expected_tck_bytes = [
                "df535b90ac99bec8be3a8add45ce77897b1e7cb1906b5cff1097d3cb142fd9d0",
                "25607e1398836b8882874bd7195a2829a506942c8d45d1e36f772d7d4c12d16e",
                "2bee15dd8e70aa9c4c8e43240eaa735d922984b33fda2a47f919ddd0d5a174cf",
                "67bcaf90bacf4a68eb9c05e433fbadef652082d3e9f1a144c0c33e6c48c9b42d",
                "a5a64f060f1b3b82c8977413b20a391053e339ec56383180efc1bb826bf65493",
                "c7e13775159649342247cea52125402da073a93ed9a36a9f8f813b96913ba1b3",
                "c8c79b595e82a9abbb04c6b16d09225433ab84d9c3c28d27736745d7d3e1d8f2",
                "4c96eb8375eb9afe693a1ef1f1c564676122c8484b3073914749a64d2f61b83a",
                "0a7a2f476f02dd720e88d5f4290656b28ca151919d67c408daa174bef8112b9e",
            ]
            let expected_tcn_bytes = [
                "f4350a4a33e30f2f568898fbe4c4cf34",
                "135eeaa6482b8852fea3544edf6eabf0",
                "d713ce68cf4127bcebde6874c4991e4b",
                "5174e6514d2086565e4ea09a45995191",
                "ccae4f2c3144ad1ed0c2a39613ef0342",
                "3b9e600991369bba3944b6e9d8fda370",
                "dc06a8625c08e946317ad4c89e6ee8a1",
                "9d671457835f2c254722bfd0de76dffc",
                "8b454d28430d3153a500359d9a49ec88",
            ]
            print("start")
            
            let startIndex : UInt16 = 500
            let endIndex : UInt16 = 505
            
            let rak = ReportAuthorizationKey(reportAuthorizationPrivateKey: try .init(rawRepresentation: expected_rak_bytes.hexDecodedData()))
            XCTAssertEqual(rak.reportAuthorizationPrivateKey.rawRepresentation.map{ String(format:"%02x", $0) }.joined() , expected_rak_bytes)
            
            print("here")
            var tck = rak.initialTemporaryContactKey
            for index in 0..<(Int(startIndex)-1) {
                if index < 9{
                    XCTAssertEqual(tck.bytes.map{ String(format:"%02x", $0) }.joined(), expected_tck_bytes[index])
                    XCTAssertEqual(tck.temporaryContactNumber.bytes.map{ String(format:"%02x", $0) }.joined(), expected_tcn_bytes[index])
                }
                tck = tck.ratchet()!
            }
            
            let timestamp = Int64(Date().timeIntervalSince1970)
            
            let signedReport = try rak.createSignedReport(
                memoType: .CoEpiV1,
                memoData: "symptom data [\(timestamp)]".data(using: .utf8)!,
                startIndex: startIndex,
                endIndex: endIndex
            )
            
            let serializedReport = try signedReport.serializedData()
//            let hexEncodedReportString = serializedReport.hexEncodedString()
            
            let request = buildUrlRequest(data: serializedReport)
            postTcnReportHelper(urlRequest: request)
            
        }
        catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    
    //MARK: Helper functions
    
    func buildUrlRequest(data: Data) -> URLRequest {
//        let urlString: String = apiV4Url //+ "/tcnreport"
        
        //https://github.com/Alamofire/Alamofire/blob/master/Documentation/AdvancedUsage.md#urlrequestconvertible
        let url = URL(string: backend.url)!
        var urlRequest = URLRequest(url: url)
        urlRequest.method = .post
        urlRequest.httpBody = data.base64EncodedData()
        
        return urlRequest
    }
    
    func buildUrlRequest(string: String) -> URLRequest {
        let paramsStringEncoded = string.toBase64()
        let data = Data(paramsStringEncoded.utf8)
        return buildUrlRequest(data: data)
    }
    
    private func getTcnForDate(_ date: Date){
        
        /*
         curl 'https://v1.api.coepi.org/tcnreport/v0.4.0?intervalNumber=18394&intervalLength=86400' && echo
         */
//        let intervalLength : Int64 = 86400
        let intervalLengthMillis : Int64 = backend.intervalLength * 1000//6 * 3600 * 1000
        let millis = Int64(date.timeIntervalSince1970 * 1000)
        let intervalNumber = millis / intervalLengthMillis
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"//"yyyy-MM-dd HH:mm:ss ZZZ"
        dateformater.timeZone = TimeZone(abbreviation: "UTC")
        let formatedDate = dateformater.string(from: date)
        
        NSLog("⚡️ IntervalLengthMillis : [\(intervalLengthMillis)]")
        NSLog("⚡️ Millis : [\(millis)]")
        NSLog("⚡️ IntervalNumber : [\(intervalNumber)]")
        NSLog("⚡️ FormatedDate : [\(formatedDate)]")
        
        //Single date has 4 6h long intervals:
        for var i : Int64 in 0...3 {
            var url: String = backend.url + "?intervalNumber=\(intervalNumber+i)"
            
            switch backend.type {
            case .aws:
                url += "&\(backend.intervalLengthParam)=\(intervalLengthMillis)"
                url += "&date=\(formatedDate)"
         
            //curl -X GET "https://zmqh8rwdx4.execute-api.us-west-2.amazonaws.com/v4/tcnreport/0.4.0?intervalNumber=73581&intervalLength=21600"
            case .golang, .aws_updated_interval_format:
                url += "&\(backend.intervalLengthParam)=\(backend.intervalLength)"
            }
            
            NSLog("\n⚡️ URL : [\(url)]")
            executeGet(url: url)
            
        }
        
    }
    
    private func executeGet(url: String){
        let expect = expectation(description: "request complete")
        
        //Fix for error message: "CredStore - performQuery - Error copying matching creds.  Error=-25300" See: https://stackoverflow.com/a/54100650
        let configuration = URLSessionConfiguration.default
        configuration.urlCredentialStorage = nil
        
        let session = Session(configuration: configuration,  eventMonitors: [ AlamofireLogger()])
        let _ = session.request(url).validate()
            .cURLDescription { description in
                NSLog(description)
            }
        .responseJSON { response in
            let statusCode = response.response?.statusCode
            NSLog("⚡️ StatusCode : [\(statusCode!)]")
            
            expect.fulfill()
            switch response.result {
            case .success(let JSON):
                NSLog("\n⚡️ Success value and JSON: \(JSON)")
                XCTAssertNotNil(JSON)
                if let stringArray = JSON as? Array<String> {
                    var i = 0
                    for s in stringArray {
                        i+=1
                        print("[\(i).]")
                        print(s)
                        guard let decodedData = Data(base64Encoded: s) else{
                            print("Unable to decode data!")
                            continue
                        }
                        
//                        guard let ps = s.fromBase64() else {continue}
//                        NSLog("⚡️ Decoded once :<\(s)> -> <\(ps)>")
                        
                        do {
                            let signedReport = try SignedReport(serializedData: decodedData)
                            do {
                                let verified = try signedReport.verify()
                                
                                if !verified {
                                    print("Verification failed!")
                                    continue
                                }
                                
                                let n1 = signedReport.report.startIndex
                                let n2 = signedReport.report.endIndex
                                let memoData = signedReport.report.memoData
                                
                                
//                                print("start = \(n1)")
                                NSLog("⚡️start = \(n1)")
                                NSLog("⚡️end = \(n2)")
                                NSLog("⚡️memoData = \(memoData)")
                                
                                if let memo : String = String(data:memoData, encoding: .utf8){
                                     NSLog("⚡️memo = \(memo)")
                                }else{
                                   NSLog("⚡️⚡️⚡️ Problem decoding memo!!!")
                                }
                                
                            }
                            catch {
                                XCTFail("Verification failed : " + error.localizedDescription)
                            }
                            
                            
                        }catch{
                            XCTFail("SignedReportInit failed : " + error.localizedDescription)
                        }
                        
//                        guard let pps =  ps.fromBase64()  else { continue }
//                        NSLog("⚡️ Decoded twice : <\(ps)> -> <\(pps)>")
                    }
                }
                
            case .failure(let error):
                NSLog("\n⚡️ Request failed with error: \(error)")
                XCTFail()
            }
            
        }
        
        waitForExpectations(timeout: 10)
        
    }
    
    private func getDateForString(_ dateString: String) -> Date?{
        let dateformater = DateFormatter()
        dateformater.dateFormat = "yyyy-MM-dd"
        dateformater.timeZone = TimeZone(abbreviation: "UTC")
        let date = dateformater.date(from: dateString)!
        return date
    }
    
}

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
}

//From TCNClient:Hex.swift
extension String {
    /// A data representation of the hexadecimal bytes in this string.
    func hexDecodedData() -> Data {
        // Get the UTF8 characters of this string
        let chars = Array(utf8)
        
        // Keep the bytes in an UInt8 array and later convert it to Data
        var bytes = [UInt8]()
        bytes.reserveCapacity(count / 2)
        
        // It is a lot faster to use a lookup map instead of strtoul
        let map: [UInt8] = [
            0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, // 01234567
            0x08, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 89:;<=>?
            0x00, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x00, // @ABCDEFG
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // HIJKLMNO
        ]
        
        // Grab two characters at a time, map them and turn it into a byte
        for i in stride(from: 0, to: count, by: 2) {
            let index1 = Int(chars[i] & 0x1F ^ 0x10)
            let index2 = Int(chars[i + 1] & 0x1F ^ 0x10)
            bytes.append(map[index1] << 4 | map[index2])
        }
        
        return Data(bytes)
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}



