import Foundation

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
        let currentCENKey = cenKeyRepo.generateAndStoreCENKey()
        return cenLogic.generateCen(CENKey: currentCENKey.cenKey)
        //*** Scenario 1: https://docs.google.com/document/d/1f65V3PI214-uYfZLUZtm55kdVwoazIMqGJrxcYNI4eg/edit#
        // iOS - Central + iOS - Peripheral -- so commenting out addNewContact
        //addNewContactEvent(with: identifier)
    }

    func provideMyCenAsync(respondClosure: (Data) -> ()) {
        respondClosure(provideMyCen())
    }
}
