import XCTest
import RxSwift
import RxAlamofire
import RxBlocking

class CoEpiNetworkingTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    /**
     Test Case '-[CoEpiNetworkingTests.CoEpiNetworkingTests testGetCoEpiCenKeys]' started.
     curl -X GET
     "https://coepi.wolk.com:8080/cenkeys" -i -v
     Success (786ms): Status 200
     (
         2C4728F76593B5A2436CC2F1A487119C,
         4CD586539DA4F15E6A374B6DFC5ABB11,
         9C19887121DA5CC271332135C1FC892C,
         8E0E4F3D55C21BC6FB8239774004FAED,
         8E0E4F3D55C21BC6FB8239774004FAED,
         8E0E4F3D55C21BC6FB8239774004FAED,
         8E0E4F3D55C21BC6FB8239774004FAED,
         8E0E4F3D55C21BC6FB8239774004FAED,
         536436159E172635C5873115D825690A,
         8E0E4F3D55C21BC6FB8239774004FAED,
         26300680c00905ba10074dc8df95f88d,
         dc3c547ec713920effa38670bc3a217c,
         17FA287EBE6B42A3859A60C12CF71394,
         B37BD3A27754BBE8479AE04F3516883E,
         E02635D8404F44D5A861A8C95605AFC5,
         17FA287EBE6B42A3859A60C12CF71394,
         811F6C0CBF954001AE2321049F4F30AB,
         B37BD3A27754BBE8479AE04F3516883E,
         17FA287EBE6B42A3859A60C12CF71394,
         811F6C0CBF954001AE2321049F4F30AB,
         EC55B22D730E108FFB509FCEE38338AD,
         41371323cc938a0e3c55b0694bfd23f5,
         b85c4b373adde4c66651ba63aef40f48,
         41371323cc938a0e3c55b0694bfd23f5,
         b85c4b373adde4c66651ba63aef40f48,
         41371323cc938a0e3c55b0694bfd23f5,
         b85c4b373adde4c66651ba63aef40f48,
         b85c4b373adde4c66651ba63aef40f48
     )
     Test Case '-[CoEpiNetworkingTests.CoEpiNetworkingTests testGetCoEpiCenKeys]' passed (0.805 seconds).
     */
    func testGetCoEpiCenKeys(){
        let stringURL = "https://coepi.wolk.com:8080/cenkeys"
        let session = URLSession.shared
        do {
            if let x = try session.rx
                .json(.get, stringURL).toBlocking().first() {
                print(x)
            } else{
                assert(false)
            }
            assert(true)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    
    /**
    Test Case '-[CoEpiNetworkingTests.CoEpiNetworkingTests testGetCoEpiCenReportForCenKey]' started.
    curl -X GET
    "https://coepi.wolk.com:8080/cenreport/17FA287EBE6B42A3859A60C12CF71394" -i -v
    Success (634ms): Status 200
    (
            {
            report = UTA5V1NVUWdNVGtnWm5KdmJTQkNRVkpV;
            reportID = 1cb7dba576e655e0e230cb6ecc680eb5a82f4deaabdb0bf6a9da253c63a1ac68;
            reportTimeStamp = 1585788223;
        },
            {
            report = UTA5V1NVUWdNVGtnWm5KdmJTQkNRVkpV;
            reportID = 20e1d663e0eb0e3881687dc78cce3e9146a63619a06555947ff9a888550dbdf8;
            reportTimeStamp = 1585788087;
        },
            {
            report = UTA5V1NVUWdNVGtnWm5KdmJTQkNRVkpV;
            reportID = 4e97044f22755565e7d68316997efbc1e7c48c98ebd6ae944d0427f2dbe2fd5e;
            reportTimeStamp = 1585788167;
        }
    )
    Test Case '-[CoEpiNetworkingTests.CoEpiNetworkingTests testGetCoEpiCenReportForCenKey]' passed (0.637 seconds).
    */
    func testGetCoEpiCenReportForCenKey(){
        let cenKey = "17FA287EBE6B42A3859A60C12CF71394"
        let stringURL = "https://coepi.wolk.com:8080/cenreport/\(cenKey)"
               let session = URLSession.shared
               do {
                   if let x = try session.rx
                       .json(.get, stringURL).toBlocking().first() {
                       print(x)
                   } else{
                       assert(false)
                   }
                   assert(true)
               } catch {
                   XCTFail("\(error)")
               }
    }
    
    
    /**
     Test Case '-[CoEpiNetworkingTests.CoEpiNetworkingTests testPostCoEpiCenReport]' started.
     reportPayload(reportID: "80d2910e783ab87837b444c224a31c9745afffaaacd4fb6eacf233b5f30e3140", report: "c2V2ZXJlIGZldmVyLGNvdWdoaW5nLGhhcmQgdG8gYnJlYXRoZQ==", cenKeys: "b85c4b373adde4c66651ba63aef40f48", reportTimestamp: 1585622040)
     {"reportTimestamp":1585622040,"cenKeys":"b85c4b373adde4c66651ba63aef40f48","report":"c2V2ZXJlIGZldmVyLGNvdWdoaW5nLGhhcmQgdG8gYnJlYXRoZQ==","reportID":"80d2910e783ab87837b444c224a31c9745afffaaacd4fb6eacf233b5f30e3140"}
     2020-04-02 16:57:40.613: CoEpiNetworkingTests.swift:178 (testPostCoEpiCenReport()) -> subscribed
     2020-04-02 16:57:40.614: CoEpiNetworkingTests.swift:178 (testPostCoEpiCenReport()) -> subscribed
     2020-04-02 16:57:40.615: CoEpiNetworkingTests.swift:178 (testPostCoEpiCenReport()) -> Event next(POST https://coepi.wolk.com:8080/cenreport/b85c4b373adde4c66651ba63aef40f48)
     2020-04-02 16:57:41.451: CoEpiNetworkingTests.swift:178 (testPostCoEpiCenReport()) -> Event next((<NSHTTPURLResponse: 0x600003f38800> { URL: https://coepi.wolk.com:8080/cenreport/b85c4b373adde4c66651ba63aef40f48 } { Status Code: 200, Headers {
         "Access-Control-Allow-Origin" =     (
             "*"
         );
         "Content-Length" =     (
             2
         );
         "Content-Type" =     (
             "text/plain; charset=utf-8"
         );
         Date =     (
             "Thu, 02 Apr 2020 14:57:41 GMT"
         );
     } }, "OK"))
     */
    func testPostCoEpiCenReport(){
        
        struct reportPayload : Encodable{
            let reportID: String
            let report: String
            let cenKeys: String
            let reportTimestamp: UInt64
        }
        
        let cenKey = "b85c4b373adde4c66651ba63aef40f48"
        let payload: reportPayload = reportPayload(reportID: "80d2910e783ab87837b444c224a31c9745afffaaacd4fb6eacf233b5f30e3140",
                                                   report: "c2V2ZXJlIGZldmVyLGNvdWdoaW5nLGhhcmQgdG8gYnJlYXRoZQ==",
                                                   cenKeys: cenKey,
                                                   reportTimestamp: 1585622040
        )
        print(payload)
        
        guard let jsonData = try? JSONEncoder().encode(payload) else{
            XCTFail("decoding error")
            return
        }
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        }
        
        let stringURL = "https://coepi.wolk.com:8080/cenreport/" + cenKey
        var request = URLRequest(url: URL(string: stringURL)!)
        //Following code to pass post json
        request.httpBody = jsonData
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let x = try RxAlamofire.request(request).debug().responseString().debug().toBlocking().first()
            print(x.debugDescription)
        }catch{
             XCTFail("\(error)")
        }
        
    }

}
