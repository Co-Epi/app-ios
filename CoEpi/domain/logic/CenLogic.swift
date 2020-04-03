import Foundation
import CryptoSwift
import os.log

class CenLogic {
    private let CENKeyLifetimeInSeconds: Int64 = 2 * 60 // TODO: revert back to 7*86400
    private let CENLifetimeInSeconds: Int64 = 1 * 60 // TODO: revert back to 15*60

    func shouldGenerateNewCenKey(curTimestamp: Int64, cenKeyTimestamp: Int64) -> Bool {
         (cenKeyTimestamp == 0) || (roundedTimestamp(ts: curTimestamp) > roundedTimestamp(ts: cenKeyTimestamp))
    }

    func generateCenKey(curTimestamp: Int64) -> CENKey {
        //generate a new AES Key and store it in local storage

        //generate base64string representation of key
        let cenKeyString = computeSymmetricKey()
        let cenKeyTimestamp = curTimestamp

        //Create CENKey and insert/save to Realm
        let newCENKey = CENKey(cenKey: cenKeyString, timestamp: cenKeyTimestamp)
        
        return newCENKey
    }

    // TODO ideally this should return Cen, not Data. Implement Cen <-> Data (separately)
    func generateCen(CENKey: String) -> Data {
        let currentTs: Int64 = Date().coEpiTimestamp
        // decode the base64 encoded key
        let decodedCENKey: Data = Data(base64Encoded: CENKey)!

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

        do {
            //encrypt tsAsUnit8Array using decodedCENKey... using AES
            let encData =
                try AES(key: decodedCENKeyAsUInt8Array, blockMode: ECB(), padding: .pkcs5).encrypt(tsAsUInt8Array)

            //return Data representation of encodedData
            return NSData(bytes: encData, length: Int(encData.count)) as Data

        } catch let error {
            os_log("Couldn't encrypt key: %@, error: %@", type: .error, CENKey, error.localizedDescription)
            // TODO better handling, return Result type or propagate error maybe.
            return Data(decodedCENKeyAsUInt8Array)
        }
    }

    private func computeSymmetricKey() -> String {
        var keyData = Data(count: 32) // 32 bytes === 256 bits
        let keyDataCount = keyData.count
        let result = keyData.withUnsafeMutableBytes {
            (mutableBytes: UnsafeMutablePointer) -> Int32 in
            SecRandomCopyBytes(kSecRandomDefault, keyDataCount, mutableBytes)
        }
        if result == errSecSuccess {
            return keyData.base64EncodedString()
        } else {
            return ""
        }
    }

    private func roundedTimestamp(ts : Int64) -> Int64 {
        Int64(ts / CENKeyLifetimeInSeconds) * CENKeyLifetimeInSeconds
    }
}
