import Foundation

// TODO review CEN refresh logic. Is it on each read or with a timer?
class ContactReceivedHandler: PeripheralRequestHandler {

    private let cenKeyRepo: CENKeyRepo
    private let cenLogic: CenLogic

    init(cenKeyRepo: CENKeyRepo, cenLogic: CenLogic) {
        self.cenKeyRepo = cenKeyRepo
        self.cenLogic = cenLogic
    }

    func onReceivedRequest(request: Data?, respondClosure: (Data) -> ()) {
        let currentCENKey = cenKeyRepo.generateAndStoreCENKey()
        let CENData: Data = cenLogic.generateCen(CENKey: currentCENKey.cenKey)
        //*** Scenario 1: https://docs.google.com/document/d/1f65V3PI214-uYfZLUZtm55kdVwoazIMqGJrxcYNI4eg/edit#
        // iOS - Central + iOS - Peripheral -- so commenting out addNewContact
        //addNewContactEvent(with: identifier)
        respondClosure(CENData)
    }
}
