import Foundation
import RxSwift

protocol CENRepo {
    func insert(cen: CEN) -> Bool

    func loadAllCENRecords() -> [CEN]?

    func match(start: UnixTime, end: UnixTime, hexEncodedCENs: [String]) -> [CEN]
    
    func loadCensForTimeInterval(start: UnixTime, end: UnixTime) -> [CEN]
}

class CENRepoImpl: CENRepo {
    private let cenDao: CENDao

    init(cenDao: CENDao) {
        self.cenDao = cenDao
    }

    func insert(cen: CEN) -> Bool {
        cenDao.insert(cen: cen)
    }

    func loadAllCENRecords() -> [CEN]? {
        cenDao.loadAllCENRecords()
    }

    func match(start: UnixTime, end: UnixTime, hexEncodedCENs: [String]) -> [CEN] {
        cenDao.match(start: start, end: end, hexEncodedCENs: hexEncodedCENs)
    }
    
    func loadCensForTimeInterval(start: UnixTime, end: UnixTime) -> [CEN] {
        cenDao.loadCensForTimeInterval(start: start, end: end)
    }
}
