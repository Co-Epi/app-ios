import CryptoSwift
import Foundation

class ContactReceivedHandler: PeripheralRequestHandler {

    private let cenKeyRepo: CENKeyRepo

    init(cenKeyRepo: CENKeyRepo) {
        self.cenKeyRepo = cenKeyRepo
    }

    func onReceivedRequest(request: Data?, respondClosure: (Data) -> ()) {
        let currentCENKey = cenKeyRepo.generateAndStoreCENKey()
        let CENData: Data = generateCENData(CENKey: currentCENKey.cenKey)
        //*** Scenario 1: https://docs.google.com/document/d/1f65V3PI214-uYfZLUZtm55kdVwoazIMqGJrxcYNI4eg/edit#
        // iOS - Central + iOS - Peripheral -- so commenting out addNewContact
        //addNewContactEvent(with: identifier)
        respondClosure(CENData)
    }

    func generateCENData(CENKey : String) -> Data {
        let currentTs : Int64 = Int64(Date().timeIntervalSince1970)
        // decode the base64 encoded key
        let decodedCENKey:Data = Data(base64Encoded: CENKey)!

        //convert key to [UInt8]
        var decodedCENKeyAsUInt8Array: [UInt8] = []
        decodedCENKey.withUnsafeBytes {
            decodedCENKeyAsUInt8Array.append(contentsOf: $0)
        }

        //convert timestamp to [UInt8]
        var tsAsUInt8Array: [UInt8] = []
        [roundedTimestamp(ts: currentTs)].withUnsafeBytes {
            tsAsUInt8Array.append(contentsOf: $0)
        }

        //encrypt tsAsUnit8Array using decodedCENKey... using AES
        let encData = try! AES(key: decodedCENKeyAsUInt8Array, blockMode: ECB(), padding: .pkcs5).encrypt(tsAsUInt8Array)

        //return Data representation of encodedData
        return NSData(bytes: encData, length: Int(encData.count)) as Data
    }
}
