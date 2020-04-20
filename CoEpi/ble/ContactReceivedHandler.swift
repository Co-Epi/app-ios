import Foundation
import os.log

// TODO review CEN refresh logic. Is it on each read or with a timer?
class ContactReceivedHandler {

    private let cenKeyRepo: CENKeyRepo
    private let cenLogic: CenLogic

    init(cenKeyRepo: CENKeyRepo, cenLogic: CenLogic) {
        self.cenKeyRepo = cenKeyRepo
        self.cenLogic = cenLogic
    }

    // TODO review CEN generation timing
    func provideMyCen() -> Data {
        switch cenKeyRepo.generateAndStoreCENKey() {
        case .success(let key):
            let cen = cenLogic.generateCen(CENKey: key.cenKey, timestamp: UnixTime.now().value)
            os_log("Generated my CEN: %@ with key: %@", log: servicesLog, cen.toHex(), "\(key.cenKey)")
            return cen
            //*** Scenario 1: https://docs.google.com/document/d/1f65V3PI214-uYfZLUZtm55kdVwoazIMqGJrxcYNI4eg/edit#
            // iOS - Central + iOS - Peripheral -- so commenting out addNewContact
            //addNewContactEvent(with: identifier)

        case .failure(let error):
            os_log("Couldn't generate CEN key: %@", type: .error, "\(error)")
            // TODO clarify with BT lib how to handle error.
            // In this case lib probably should handle optional result (do nothing if it's not set)
            // or maybe use callback
            return Data()
        }
    }

    func provideMyCenAsync(respondClosure: (Data) -> ()) {
        respondClosure(provideMyCen())
    }
}
