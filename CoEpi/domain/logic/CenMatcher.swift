import Foundation
import os.log

protocol CenMatcher {
    func hasMatches(key: CENKey, maxTimestamp: UnixTime) -> Bool
    func matchLocalFirst(keys: [CENKey], maxTimestamp: UnixTime) -> [CENKey]
}

class CenMatcherImpl: CenMatcher {
    private let cenRepo: CENRepo // TODO decouple from DB
    private let cenLogic: CenLogic
    
    var matchedKeys : [CENKey] = []
    //Concurent queue on which to run matching tasks
    private let matchingQueue = DispatchQueue(label: "org.coepi.matchingQueue", attributes: .concurrent)

    init(cenRepo: CENRepo, cenLogic: CenLogic) {
        self.cenRepo = cenRepo
        self.cenLogic = cenLogic
    }

    func hasMatches(key: CENKey, maxTimestamp: UnixTime) -> Bool {
        !match(key: key, maxTimestamp: maxTimestamp).isEmpty
    }
    
    func matchLocalFirst(keys: [CENKey], maxTimestamp: UnixTime) -> [CENKey] {
        let modulus = maxTimestamp.value % Int64(CenLogic.CENLifetimeInSeconds)
        let roundedMaxTimestamp = maxTimestamp.value - modulus
        let minTimestamp: Int64 = roundedMaxTimestamp - 7*24*60*60
        
        let localCens: [CEN] = cenRepo.loadCensForTimeInterval(
            start: UnixTime(value: minTimestamp),
            end: maxTimestamp
        )

        os_log("Count of local CENs = %{public}d", localCens.count)
        
        let concurrentMatchingGroup: DispatchGroup = DispatchGroup()
        let matchingIsCompleteSemaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        
        for localCen in localCens {
            concurrentMatchingGroup.enter()
            matchingQueue.async {
                self.checkForPotentialInfection(cen: localCen, infectedKeys: keys){concurrentMatchingGroup.leave()}
            }
        }
        concurrentMatchingGroup.notify(queue: DispatchQueue.main){
            //All matching batches are done
            os_log("Matching is completed!")
            matchingIsCompleteSemaphore.signal()
        }
        
        //Block execution until all matching batches are done
        matchingIsCompleteSemaphore.wait()
        
        return matchedKeys
        
    }
    
    private func checkForPotentialInfection(cen: CEN, infectedKeys: [CENKey], completion: () -> Void){
        let mod = cen.timestamp.value % Int64(CenLogic.CENLifetimeInSeconds)
        let roundedLocalTimestamp = cen.timestamp.value - mod
        let previousRoundedLocalTimestamp = roundedLocalTimestamp - CenLogic.CENLifetimeInSeconds
//        os_log("Local CEN: cen = [ %{public}@ ], timestamp = [ %lld ], rounded timestamp = [ %lld ]", cen.CEN, cen.timestamp, roundedLocalTimestamp)

        for key in infectedKeys {
            if matchKeyForTimestamp(key: key, cen: cen, timestamp: roundedLocalTimestamp) {
                break
            }
            if matchKeyForTimestamp(key: key, cen: cen, timestamp: previousRoundedLocalTimestamp) {
                break
            }
        }
        //leave concurrentMatchingGroup
        completion()
    }
    
    private func matchKeyForTimestamp(key: CENKey, cen: CEN, timestamp: Int64) -> Bool{
        let candidateCen = cenLogic.generateCen(CENKey: key.cenKey, timestamp: timestamp)
        let candidateCenHex = candidateCen.toHex()
        if cen.CEN == candidateCenHex {
//            os_log("Match found for [ %{public}@ ]", candidateCenHex)
            //Update matchedKeys on Main thread (preventing race conditions)
            DispatchQueue.main.async{
                self.matchedKeys.append(key)
            }
            return true
        }
        
        return false
    }

    // Copied from Android implementation
    private func match(key: CENKey, maxTimestamp: UnixTime) -> [CEN] {
        let interval: Int64 = 7 * 24 * 60 * 60
        
        // take the last 7 days of timestamps and generate all the possible CENs (e.g. 7 days) TODO: Parallelize this?
        let minTimestamp: Int64 = maxTimestamp.value - interval
        let CENLifetimeInSeconds = 15 * 60   // every 15 mins a new CEN is generated

        // last time (unix timestamp) the CENKeys were requested

        let max = Int(Double(interval)/Double(CENLifetimeInSeconds))

        var possibleCENs: [String] = []
        possibleCENs.reserveCapacity(max)

        for i in 0...max {
            let ts = maxTimestamp.value - Int64(CENLifetimeInSeconds * i)
            let cen = cenLogic.generateCen(CENKey: key.cenKey, timestamp: ts)
//            possibleCENs[i] = cen.toHex()
            possibleCENs.append(cen.toHex()) // No fixed size array
        }

        os_log("Generated results for key: %@, possible CENs count: %@, CENs: %@", log: servicesLog, type: .debug, key.cenKey,
               "\(possibleCENs.count)", "\(possibleCENs)")

//        let currentlyStoredCens = cenRepo.loadAllCENRecords()
//        os_log("Currently stored CENs: %@, minTime: %@, maxtime: %@", log: servicesLog, type: .debug,
//               "\(String(describing: currentlyStoredCens))", "\(minTimestamp)", "\(maxTimestamp)")

        return cenRepo.match(start: UnixTime(value: minTimestamp), end: maxTimestamp, hexEncodedCENs: possibleCENs)
    }
}
