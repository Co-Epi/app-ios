import CoreBluetooth
import Foundation
import os.log
import RxRelay

protocol PeripheralReactive {
    var peripheralState: BehaviorRelay<String> { get }

    var didReadCharacteristic: PublishRelay<BTContact> { get }
}

protocol PeripheralRequestHandler: class {
    func onReceivedRequest(request: Data?, respondClosure: (Data) -> ())
}

class PeripheralImpl: NSObject, PeripheralReactive {
    let peripheralState: BehaviorRelay<String> = BehaviorRelay(value: "unknown")
    let didReadCharacteristic: PublishRelay<BTContact> = PublishRelay()
    private let internalDelegate: PeripheralRequestHandler
    
    private var peripheralManager: CBPeripheralManager!

    private let serviceUuid: CBUUID = CBUUID(nsuuid: Uuids.service)
    private let characteristicUuid: CBUUID = CBUUID(nsuuid: Uuids.characteristic)

    init(internalDelegate: PeripheralRequestHandler) {
        self.internalDelegate = internalDelegate
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
            peripheralState.accept("unknown")
        case .unsupported:
            peripheralState.accept("unsupported")
        case .unauthorized:
            peripheralState.accept("unauthorized")
        case .resetting:
            peripheralState.accept("resetting")
        case .poweredOff:
            peripheralState.accept("poweredOff")
        case .poweredOn:
            peripheralState.accept("poweredOn")
            startAdvertising()
        @unknown default:
            os_log("Peripheral state: unknown")
        }
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
        os_log("Peripheral manager did receive read request: %@", log: blePeripheralLog, request.description)

        let respondClosure: (Data) -> () = { [weak self] (responseData) in
            // do we need to capture request & peripheral?
            let theirData: Data? = request.value
            request.value = responseData
            peripheral.respond(to: request, withResult: .success)

            let contact: BTContact = .init(theirData: theirData, ourData: responseData)
            self?.didReadCharacteristic.accept(contact)
        }
        
        internalDelegate.onReceivedRequest(request: request.value, respondClosure: respondClosure)
        
        os_log("Peripheral manager did respond to read request with result: %d", log: blePeripheralLog, CBATTError.success.rawValue)
    }
}


