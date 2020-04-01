import Foundation

let CENKeyLifetimeInSeconds: Int64 = 2*60 //TODO: revert back to 7*86400
let CENLifetimeInSeconds: Int64 = 1*60 //TODO: revert back to 15*60

func roundedTimestamp(ts : Int64) -> Int64 {
    Int64(ts / CENKeyLifetimeInSeconds)*CENKeyLifetimeInSeconds
}
