import Foundation
import RxSwift

protocol CENRepo {
    func insert(cen: CEN) -> Bool

    func loadAllCENRecords() -> [CEN]?
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
}
