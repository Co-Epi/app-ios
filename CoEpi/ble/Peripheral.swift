import Foundation
import CoreBluetooth
import os.log
import RxRelay

protocol Peripheral {
    var peripheralState: PublishRelay<String> { get }
    var peripheralContactSent: PublishRelay<Contact> { get }
}

class PeripheralImpl: NSObject, Peripheral {
    let peripheralState: PublishRelay<String> = PublishRelay()
    let peripheralContactSent: PublishRelay<Contact> = PublishRelay()

    private var peripheralManager: CBPeripheralManager!

    private let serviceUuid: CBUUID = CBUUID(nsuuid: Uuids.service)
    private let characteristicUuid: CBUUID = CBUUID(nsuuid: Uuids.characteristic)

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    private func startAdvertising() {
        let service = createService()
        peripheralManager.add(service)

        peripheralManager.startAdvertising([
            // NOTE/TODO this identifier is supposed to show directly in discovery. It doesn't. Service is listed in iPhone peripheral.
            CBAdvertisementDataLocalNameKey : "BLEPeripheralApp",

            CBAdvertisementDataServiceUUIDsKey : [serviceUuid]
        ])
    }

    private func createService() -> CBMutableService {
        let service = CBMutableService(type: serviceUuid, primary: true)

        let characteristic = CBMutableCharacteristic(
            type: characteristicUuid,
            properties: [.read],
            value: nil,
            permissions: [.readable]
        )
        service.characteristics = [characteristic]

        os_log("Peripheral manager adding service: %@", log: blePeripheralLog, service)

        return service
    }
}

extension PeripheralImpl: CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .unknown:
            report(state: "unknown")
        case .unsupported:
            report(state: "unsupported")
        case .unauthorized:
            report(state: "unauthorized")
        case .resetting:
            report(state: "resetting")
        case .poweredOff:
            report(state: "poweredOff")
        case .poweredOn:
            report(state: "poweredOn")
            startAdvertising()
        @unknown default:
            os_log("Peripheral state: unknown")
        }
    }

    private func report(state: String) {
        peripheralState.accept(state)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            os_log("Advertising error: %@", log: blePeripheralLog, type: .error, error.localizedDescription)
        } else {
            os_log("Peripheral manager did add service: %@", log: blePeripheralLog, service)
        }
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            os_log("Advertising error: %@", log: blePeripheralLog, type: .error, error.localizedDescription)
        } else {
            os_log("Peripheral manager starting advertising", log: blePeripheralLog)
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        os_log("Peripheral manager did receive read request: %@", request.description)

        let identifier = UUID()
        addNewContactEvent(with: identifier)
        request.value = identifier.dataRepresentation
        peripheral.respond(to: request, withResult: .success)

        os_log("Peripheral manager did respond to read request with result: %d", CBATTError.success.rawValue)
    }

    private func addNewContactEvent(with identifier: UUID) {
        peripheralContactSent.accept(Contact(
            identifier: identifier,
            timestamp: Date(),
            // TODO preference
            isPotentiallyInfectious: true
        ))
    }
}

struct Contact {
    let identifier: UUID
    let timestamp: Date
    let isPotentiallyInfectious: Bool
}
