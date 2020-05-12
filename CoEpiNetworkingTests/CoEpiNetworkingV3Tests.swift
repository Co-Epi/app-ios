import XCTest
import Foundation
import Alamofire

//@testable import CoEpi

//final class AlamofireLogger: EventMonitor {
//    func requestDidResume(_ request: Request) {
//        let body = request.request.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
//        let message = """
//        ⚡️ Request Started: \(request)
//        ⚡️ Body Data: \(body)
//        """
//        NSLog(message)
//    }
//
//    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, Error>) {
//        NSLog("⚡️ Response Received: \(response.debugDescription)")
//    }
//}

struct ReportPayloadV3 : Codable{
    let report: String
    let cenKeys: [String]
}

class CoEpiNetworkingV3Tests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        //https://q69c4m2myb.execute-api.us-west-2.amazonaws.com/v3
        /**
         curl -X POST https://q69c4m2myb.execute-api.us-west-2.amazonaws.com/v3/cenreport -d '{ "report": "dWlyZSBhdXRob3JgdsF0aW9uLgo=", "cenKeys": [ "baz1", "das1" ]}'

         curl -X GET https://q69c4m2myb.execute-api.us-west-2.amazonaws.com/v3/cenreport
         [{"did":"2020-04-06","reportTimestamp":1586157667433,"report":"dWlyZSBhdXRob3JpemF0aW9uLgo=","cenKeys":["bar","foo"]},{"did":"2020-04-06","reportTimestamp":1586158348099,"report":"dWlyZSBhdXRob3JpemF0aW9uLgo=","cenKeys":["bar","foo"]},{"did":"2020-04-06","reportTimestamp":1586158404001,"report":"dWlyZSBhdXRob3JgdsF0aW9uLgo=","cenKeys":["baz","das"]}]
         TO DO
         */
    }
    
    /**
     Test Case '-[CoEpiNetworkingTests.CoEpiNetworkingV3Tests testV3getCenReport]' started.
     2020-04-07 19:03:10.734795+0200 xctest[18155:13774196] ⚡️ Request Started: GET https://q69c4m2myb.execute-api.us-west-2.amazonaws.com/v3/cenreport
     ⚡️ Body Data: None


      Success value and JSON: (
             {
             cenKeys =         (
                 baz1,
                 das1
             );
             did = "2020-04-07";
             report = "dWlyZSBhdXRob3JgdsF0aW9uLgo=";
             reportTimestamp = 1586278840644;
         }
     )
     Test Case '-[CoEpiNetworkingTests.CoEpiNetworkingV3Tests testV3getCenReport]' passed (22.335 seconds).
     */
    
    func testV3getCenReport() {
        
        let url: String = "https://q69c4m2myb.execute-api.us-west-2.amazonaws.com/v3/cenreport"
        let expect = expectation(description: "request complete")
        let session = Session(eventMonitors: [ AlamofireLogger() ])
        
        let _ = session.request(url).responseJSON { response in
            expect.fulfill()
            switch response.result {
            case .success(let JSON):
                print("\n\n Success value and JSON: \(JSON)")
                XCTAssertNotNil(JSON)

            case .failure(let error):
                print("\n\n Request failed with error: \(error)")
                XCTFail()
            }
            
        }
        
        waitForExpectations(timeout: 5)

               // Then
//               XCTAssertNotNil(data)
    }
    
    func testV3postCenReport() {
        let url: String = "https://q69c4m2myb.execute-api.us-west-2.amazonaws.com/v3/cenreport"
        let expect = expectation(description: "request complete")
        let session = Session(eventMonitors: [ AlamofireLogger() ])
        /**
         { "report": "dWlyZSBhdXRob3JgdsF0aW9uLgo=", "cenKeys": [ "baz1", "das1" ]}
         
         Test Case '-[CoEpiNetworkingTests.CoEpiNetworkingV3Tests testV3postCenReport]' started.
         2020-04-07 19:57:27.516859+0200 xctest[18521:13805023] ⚡️ Request Started: POST https://q69c4m2myb.execute-api.us-west-2.amazonaws.com/v3/cenreport
         ⚡️ Body Data: {
           "report" : "dWlyZSBhdXRob3JgdsF0aW9uLgo=",
           "cenKeys" : [
             "alpha",
             "beta"
           ]
         }
         Test Case '-[CoEpiNetworkingTests.CoEpiNetworkingV3Tests testV3postCenReport]' passed (0.583 seconds).
         
         */
        
        if let key1 = makeRandomCENKey(), let key2 = makeRandomCENKey(){
            let params : ReportPayloadV3 = ReportPayloadV3(report: "dWlyZSBhdXRob3JgdsF0aW9uLgo=", cenKeys: [key1.cenKey, key2.cenKey])
            
            do {
                let _ = session.request(url, method: HTTPMethod.post, parameters: params, encoder: JSONParameterEncoder.prettyPrinted).response { response in
                    switch response.result {
                    case .success:
                        expect.fulfill()
                    case .failure(let error):
                        print("\n\n Request failed with error: \(error)")
                        XCTFail()
                    }
                    
                }
            }
        }
        
        waitForExpectations(timeout: 15)
        
    }
    
    func testCenLogic(){
        let cenLogic = CenLogic()
        
        switch cenLogic.generateCenKey(curTimestamp: Date().coEpiTimestamp) {
            case .success(let key):
                let payload = ReportPayloadV3(report: "dWlyZSBhdXRob3JgdsF0aW9uLgo=", cenKeys: [key.cenKey])
                print(payload)
                XCTAssert(true)
            case .failure(let error):
                XCTFail(error.localizedDescription)
        }
        
    }
    
    private func makeRandomCENKey() -> CENKey? {
        let cenLogic = CenLogic()
        var generatedKey : CENKey?
       switch cenLogic.generateCenKey(curTimestamp: Date().coEpiTimestamp) {
           case .success(let key):
               generatedKey = key
           case .failure(let error):
            fatalError(error.localizedDescription)
       }
        
        return generatedKey
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

