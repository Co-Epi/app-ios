import Foundation

extension Date {

    var coEpiTimestamp: Int64 {
        Int64(self.timeIntervalSince1970)
    }
}
