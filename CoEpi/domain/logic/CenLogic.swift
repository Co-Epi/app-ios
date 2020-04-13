import Foundation
import CryptoSwift
import os.log

class CenLogic {
    private let CENKeyLifetimeInSeconds: Int64 = 7 * 86400
    static let CENLifetimeInSeconds: Int64 = 15 * 60

    func shouldGenerateNewCenKey(curTimestamp: Int64, cenKeyTimestamp: Int64) -> Bool {
         (cenKeyTimestamp == 0) || (roundedTimestamp(ts: curTimestamp, roundingInterval: CENKeyLifetimeInSeconds) > roundedTimestamp(ts: cenKeyTimestamp, roundingInterval: CENKeyLifetimeInSeconds))
    }

    func generateCenKey(curTimestamp: Int64) -> Result<CENKey, CenLogicError> {
        //generate a new AES Key and store it in local storage

        //generate hex representation of key
        let cenKeyString = computeSymmetricKey()

        return cenKeyString.map {
            CENKey(cenKey: $0, timestamp: curTimestamp)
        }
    }

    // TODO ideally this should return Cen, not Data. Implement Cen <-> Data (separately)
    func generateCen(CENKey: String, timestamp: Int64) -> Data {
        // decode the hex encoded key
        let decodedCENKey: Data = Data(hex: CENKey)

        //convert key to [UInt8]
        var decodedCENKeyAsUInt8Array: [UInt8] = []
        decodedCENKey.withUnsafeBytes {
            decodedCENKeyAsUInt8Array.append(contentsOf: $0)
        }

        //convert timestamp to [UInt8]
        var tsAsUInt8Array: [UInt8] = []
        [roundedTimestamp(ts: timestamp, roundingInterval: CenLogic.CENLifetimeInSeconds)].withUnsafeBytes {
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

    private func computeSymmetricKey() -> Result<String, CenLogicError> {
        var keyData = Data(count: 32)
        let keyDataCount = keyData.count
        let result = keyData.withUnsafeMutableBytes {
            (mutableBytes: UnsafeMutablePointer) -> Int32 in
            SecRandomCopyBytes(kSecRandomDefault, keyDataCount, mutableBytes)
        }
        if result == errSecSuccess {
            return .success(keyData.toHex())
        } else {
            return .failure(.couldNotComputeKey)
        }
    }

    private func roundedTimestamp(ts : Int64, roundingInterval: Int64) -> Int64 {
        let mod = ts % roundingInterval
        let roundedTimestamp = ts - mod
        return roundedTimestamp
    }
}

public enum CenLogicError: Error {
    case couldNotComputeKey
}

