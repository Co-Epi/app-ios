protocol CENKeyRepo {
    func generateAndStoreCENKey() -> Result<CENKey, DaoError>

    func getCENKeys(limit: Int64) -> [CENKey]

    func insert(key: CENKey) -> Bool
}

class CENKeyRepoImpl: CENKeyRepo {
    let cenKeyDao: CENKeyDao

    init(cenKeyDao: CENKeyDao) {
        self.cenKeyDao = cenKeyDao
    }

    func generateAndStoreCENKey() -> Result<CENKey, DaoError> {
        cenKeyDao.generateAndStoreCENKey()
    }

    func getCENKeys(limit: Int64) -> [CENKey] {
        cenKeyDao.getCENKeys(limit: limit)
    }

    func insert(key: CENKey) -> Bool {
        cenKeyDao.insert(key: key)
    }
}
