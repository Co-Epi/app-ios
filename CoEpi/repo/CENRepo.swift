import Foundation
import RxSwift

protocol CENRepo {
    func insert(cen: CEN) -> Bool

    func loadAllCENRecords() -> [CEN]?

    func match(start: Int64, end: Int64, hexEncodedCENs: [String]) -> [CEN]
    
    func loadCensForTimeInterval(start: Int64, end: Int64) -> [CEN]
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

    func match(start: Int64, end: Int64, hexEncodedCENs: [String]) -> [CEN] {
        cenDao.match(start: start, end: end, hexEncodedCENs: hexEncodedCENs)
    }
    
    func loadCensForTimeInterval(start: Int64, end: Int64) -> [CEN] {
        cenDao.loadCensForTimeInterval(start: start, end: end)
    }
}
