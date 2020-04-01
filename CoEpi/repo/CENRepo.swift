import Foundation

protocol CENRepo {
    func insert(cen: CEN) -> Bool

    func loadAllCENRecords() -> [CEN]?
}
