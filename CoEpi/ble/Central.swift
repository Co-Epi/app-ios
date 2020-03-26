// Refactored from https://github.com/covid19risk/covidwatch-ios/blob/master/COVIDWatch%20iOS/Bluetooth/BluetoothController.swift

import Foundation
import CoreBluetooth
import os.log
import UIKit
import RxRelay

struct DetectedPeripheral {
    let uuid: UUID
    let name: String?
}


protocol Central {
    var discovery: PublishRelay<DetectedPeripheral> { get }
    var centralContactReceived: PublishRelay<Contact> { get }
}

class CentralImpl: NSObject, Central {
    let discovery: PublishRelay<DetectedPeripheral> = PublishRelay()
    let centralContactReceived: PublishRelay<Contact> = PublishRelay()

    private var centralManager: CBCentralManager!

    private var peripheral: CBPeripheral!

    private var discoveredPeripherals = Set<CBPeripheral>()

    private var discoveringServicesPeripheralIdentifiers = Set<UUID>()
    private var readingConfigurationCharacteristics = Set<CBCharacteristic>()

    private var peripheralsToReadConfigurationsFrom = Set<CBPeripheral>()
    private var peripheralsToConnect: Set<CBPeripheral> {
        Set(peripheralsToReadConfigurationsFrom)
    }

    private var connectingPeripheralIdentifiers = Set<UUID>() {
        didSet {
            handleConnectingConnectedPeripheralIdentifiersChange()
        }
    }
    
    private var connectedPeripheralIdentifiers = Set<UUID>() {
        didSet {
            handleConnectingConnectedPeripheralIdentifiersChange()
        }
    }

    private var connectingConnectedPeripheralIdentifiers: Set<UUID> {
        connectingPeripheralIdentifiers.union(connectedPeripheralIdentifiers)
    }

    #if os(watchOS)
    private let maxNumberOfConcurrentPeripheralConnections = 2
    #else
    private let maxNumberOfConcurrentPeripheralConnections = 5
    #endif

    private var connectingTimeoutTimersForPeripheralIdentifiers = [UUID : Timer]()
    public let label = UUID().uuidString
    lazy private var dispatchQueue: DispatchQueue =
        DispatchQueue(label: label, qos: .userInteractive)

    // macCatalyst apps do not need background tasks.
    // watchOS apps do not have background tasks.
    #if canImport(UIKit) && !targetEnvironment(macCatalyst) && !os(watchOS)
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?

    private func handleConnectingConnectedPeripheralIdentifiersChange() {
        #if canImport(UIKit) && !targetEnvironment(macCatalyst) && !os(watchOS)
        if connectingPeripheralIdentifiers.isEmpty &&
            connectedPeripheralIdentifiers.isEmpty {
            endBackgroundTaskIfNeeded()
        } else {
            beginBackgroundTaskIfNeeded()
        }
        #endif
    }

    private func beginBackgroundTaskIfNeeded() {
        guard backgroundTaskIdentifier == nil else { return }
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask {
            os_log("Did expire background task", log: bleCentralLog)
            self.endBackgroundTaskIfNeeded()
        }
    }

    private func endBackgroundTaskIfNeeded() {
        if let identifier = backgroundTaskIdentifier {
            backgroundTaskIdentifier = nil
            UIApplication.shared.endBackgroundTask(identifier)
        }
    }
    #endif

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)

        // macCatalyst apps do not need background support.
        // watchOS apps do not have background tasks.
        #if canImport(UIKit) && !targetEnvironment(macCatalyst) && !os(watchOS)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(applicationWillEnterForegroundNotification(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        #endif
    }

    // MARK: - Notifications

    @objc func applicationWillEnterForegroundNotification(_ notification: Notification) {
        dispatchQueue.async { [weak self] in
            guard let self = self else { return }
            // Bug workaround: If Bluetooth was toggled while the app was in the
            // background then scanning fails when the app becomes active.
            // Restart scanning now.
            if self.centralManager?.isScanning ?? false {
                self.centralManager?.stopScan()
                self.startScan()
            }
        }
    }

    deinit {
        #if canImport(UIKit) && !targetEnvironment(macCatalyst) && !os(watchOS)
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(
            self,
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        #endif
    }

    private func startScan() {
        let services = servicesToScan()
        centralManager.scanForPeripherals(
            withServices: services,
            options: [
                CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(booleanLiteral: true)
            ]
        )
        os_log("Central manager scanning for peripherals with services=%@", log: bleCentralLog, services ?? [])
    }

    private func servicesToScan() -> [CBUUID]? {
        #if targetEnvironment(macCatalyst)
        // CoreBluetooth on macCatalyst doesn't discover services of iOS apps
        // running in the background. Therefore we scan for everything.
        return nil
        #else
        return [CBUUID(string: Uuids.service.uuidString)]
        #endif
    }

    private func connectPeripheralsIfNeeded() {
        guard
            peripheralsToConnect.count > 0,
            connectingConnectedPeripheralIdentifiers.count < maxNumberOfConcurrentPeripheralConnections
            else { return }

        let disconnectedPeripherals = self.peripheralsToConnect.filter {
            $0.state == .disconnected || $0.state == .disconnecting
        }
        disconnectedPeripherals.prefix(
            maxNumberOfConcurrentPeripheralConnections - connectingConnectedPeripheralIdentifiers.count
        ).forEach {
            connectIfNeeded(peripheral: $0)
        }
    }

    private func connectIfNeeded(peripheral: CBPeripheral) {
        if peripheral.state != .connected && peripheral.state != .connecting {
            centralManager?.connect(peripheral, options: nil)

            os_log(
                "Central manager connecting peripheral (uuid: %@ name: %@)",
                log: bleCentralLog,
                peripheral.identifier.description,
                peripheral.name ?? ""
            )

            setupConnectingTimeoutTimer(for: peripheral)
            connectingPeripheralIdentifiers.insert(peripheral.identifier)

        } else {
            centralManager(centralManager, didConnect: peripheral)
        }
    }

    private func setupConnectingTimeoutTimer(for peripheral: CBPeripheral) {
        let timer = Timer.init(
            timeInterval: .peripheralConnectingTimeout,
            target: self,
            selector: #selector(connectingTimeoutTimerFired(timer:)),
            userInfo: ["peripheral" : peripheral],
            repeats: false
        )
        timer.tolerance = 0.5
        RunLoop.main.add(timer, forMode: .common)
        connectingTimeoutTimersForPeripheralIdentifiers[peripheral.identifier]?.invalidate()
        connectingTimeoutTimersForPeripheralIdentifiers[peripheral.identifier] = timer
    }

    @objc private func connectingTimeoutTimerFired(timer: Timer) {
        let userInfo = timer.userInfo

        self.dispatchQueue.async { [weak self] in
            guard
                let self = self,
                let userInfo = userInfo as? [AnyHashable : Any],
                let peripheral = userInfo["peripheral"] as? CBPeripheral
                else { return }

            if peripheral.state != .connected {
                os_log(
                    "Connecting did time out for peripheral (uuid=%@ name='%@')",
                    log: bleCentralLog,
                    peripheral.identifier.description,
                    peripheral.name ?? ""
                )
                self.flushPeripheral(peripheral)
            }
        }
    }

    private func flushPeripheral(_ peripheral: CBPeripheral) {
        peripheralsToReadConfigurationsFrom.remove(peripheral)
        discoveredPeripherals.remove(peripheral)
        cancelConnectionIfNeeded(for: peripheral)
    }

    private func cancelConnectionIfNeeded(for peripheral: CBPeripheral) {
        connectingTimeoutTimersForPeripheralIdentifiers[peripheral.identifier]?.invalidate()
        connectingTimeoutTimersForPeripheralIdentifiers[peripheral.identifier] = nil

        if peripheral.state == .connecting || peripheral.state == .connected {
            centralManager?.cancelPeripheralConnection(peripheral)
            os_log(
                "Central manager cancelled peripheral (uuid=%@ name='%@') connection",
                log: bleCentralLog,
                peripheral.identifier.description,
                peripheral.name ?? ""
            )
        }
        peripheral.delegate = nil

        connectingPeripheralIdentifiers.remove(peripheral.identifier)
        connectedPeripheralIdentifiers.remove(peripheral.identifier)

        discoveringServicesPeripheralIdentifiers.remove(peripheral.identifier)

        peripheral.services?.forEach {
            $0.characteristics?.forEach {
                readingConfigurationCharacteristics.remove($0)
            }
        }

        connectPeripheralsIfNeeded()
    }

}

extension CentralImpl: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        os_log("Central manager did update state: %d", log: bleCentralLog, central.state.rawValue)
        if central.state == .poweredOn {
            startScan()
            centralManager.scanForPeripherals(withServices: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {

        self.peripheral = peripheral
//        centralManager.stopScan()

//        os_log("advertisementData: %@", log: bleCentralLog, advertisementData)

        if !discoveredPeripherals.contains(peripheral) {
            discovery.accept(DetectedPeripheral(uuid: peripheral.identifier, name: peripheral.name))

            os_log(
                "Central manager did discover new peripheral (uuid: %@ name: %@) RSSI: %d",
                log: bleCentralLog,
                peripheral.identifier.description,
                peripheral.name ?? "",
                RSSI.intValue
            )
            peripheralsToReadConfigurationsFrom.insert(peripheral)
        }

        discoveredPeripherals.insert(peripheral)
        connectPeripheralsIfNeeded()
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        os_log(
            "Central manager did connect peripheral (uuid: %@ name: %@)",
            log: bleCentralLog,
            peripheral.identifier.description,
            peripheral.name ?? ""
        )

        connectingTimeoutTimersForPeripheralIdentifiers[peripheral.identifier]?.invalidate()
        connectingTimeoutTimersForPeripheralIdentifiers[peripheral.identifier] = nil
        connectingPeripheralIdentifiers.remove(peripheral.identifier)

        // Bug workaround: Ignore duplicate connect messages from CoreBluetooth
        guard
            !connectedPeripheralIdentifiers.contains(peripheral.identifier)
            else { return }

        connectedPeripheralIdentifiers.insert(peripheral.identifier)

        discoverServices(for: peripheral)
    }

    private func discoverServices(for peripheral: CBPeripheral) {
        guard
            !discoveringServicesPeripheralIdentifiers.contains(peripheral.identifier)
            else { return }

        discoveringServicesPeripheralIdentifiers.insert(peripheral.identifier)
        peripheral.delegate = self

        if peripheral.services == nil {
            let services = [CBUUID(string: Uuids.service.uuidString)]
            peripheral.discoverServices(services)

            os_log(
                "Central manager peripheral: (uuid: %@ name: %@) discovering services: %@",
                log: bleCentralLog,
                peripheral.identifier.description,
                peripheral.name ?? "",
                services
            )
        } else {
            peripheralShared(peripheral, didDiscoverServices: nil)
        }
    }

    private func addNewContactEvent(with identifier: UUID) {
        centralContactReceived.accept(Contact(
            identifier: identifier,
            timestamp: Date(),
            // TODO preference
            isPotentiallyInfectious: true
        ))
    }

    private func peripheralShared(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        discoveringServicesPeripheralIdentifiers.remove(peripheral.identifier)

        guard error == nil else {
            cancelConnectionIfNeeded(for: peripheral)
            return
        }

        guard let services = peripheral.services, services.count > 0 else {
            peripheralsToReadConfigurationsFrom.remove(peripheral)
            cancelConnectionIfNeeded(for: peripheral)
            return
        }

        let servicesWithCharacteristicsToDiscover = services.filter {
            $0.characteristics == nil
        }
        if servicesWithCharacteristicsToDiscover.count == 0 {
            startTransfers(for: peripheral)

        } else {
            servicesWithCharacteristicsToDiscover.forEach { service in
                let characteristics = [ CBUUID(string: Uuids.characteristic.uuidString) ]
                peripheral.discoverCharacteristics(characteristics, for: service)

                os_log(
                    "Peripheral (uuid: %@ name: %@) discovering characteristics: %@ for service: %@",
                    log: bleCentralLog,
                    peripheral.identifier.description,
                    peripheral.name ?? "",
                    characteristics.description,
                    service.description
                )
            }
        }
    }
}


extension CentralImpl: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services {
          os_log("service: %@", log: bleCentralLog, service)
        }

        peripheralShared(peripheral, didDiscoverServices: error)
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        if let error = error {
            os_log(
                "Peripheral (uuid: %@ name: %@) did discover characteristics for service: %@ error: %@",
                log: bleCentralLog,
                type: .error,
                peripheral.identifier.description,
                peripheral.name ?? "",
                service.description,
                error as CVarArg
            )

        } else {
            os_log(
                "Peripheral (uuid: %@ name: %@) did discover characteristics for service: %@",
                log: bleCentralLog,
                peripheral.identifier.description,
                peripheral.name ?? "",
                service.description
            )
        }

        guard error == nil, let services = peripheral.services else {
            cancelConnectionIfNeeded(for: peripheral)
            return
        }
        let servicesWithCharacteristicsToDiscover = services.filter {
            $0.characteristics == nil
        }
        if servicesWithCharacteristicsToDiscover.count == 0 {
            startTransfers(for: peripheral)
        }
    }

    private func shouldReadConfigurations(from peripheral: CBPeripheral) -> Bool {
        return self.peripheralsToReadConfigurationsFrom.contains(peripheral)
    }

    private func startTransfers(for peripheral: CBPeripheral) {
        guard let services = peripheral.services else {
            self.cancelConnectionIfNeeded(for: peripheral)
            return
        }
        services.forEach { service in
            peripheralShared(peripheral, didDiscoverCharacteristicsFor: service, error: nil)
        }
    }

    func peripheralShared(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                          error: Error?) {
        guard error == nil else {
            cancelConnectionIfNeeded(for: peripheral)
            return
        }

        // Read configuration, if needed
        if let configurationCharacteristic = service.characteristics?.first(where: {
            $0.uuid == CBUUID(string: Uuids.characteristic.uuidString)
        }), shouldReadConfigurations(from: peripheral) {

            if !readingConfigurationCharacteristics.contains(configurationCharacteristic) {
                readingConfigurationCharacteristics.insert(configurationCharacteristic)
                peripheral.readValue(for: configurationCharacteristic)

                os_log(
                    "Peripheral (uuid: %@ name: %@) reading value for characteristic: %@ for service: %@",
                    log: bleCentralLog,
                    peripheral.identifier.description,
                    peripheral.name ?? "",
                    configurationCharacteristic.description,
                    service.description
                )
            }
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error = error {
            os_log(
                "Peripheral (uuid: %@ name: '%@') did update value for characteristic: %@ for service: %@ error: %@",
                log: bleCentralLog,
                type: .error,
                peripheral.identifier.description,
                peripheral.name ?? "",
                characteristic.description,
                characteristic.service.description,
                error as CVarArg
            )
        }
        else {
            os_log(
                "Peripheral (uuid: %@ name: '%@') did update value: %{iec-bytes}d for characteristic: %@ for service: %@",
                log: bleCentralLog,
                peripheral.identifier.description,
                peripheral.name ?? "",
                characteristic.value?.count ?? 0,
                characteristic.description,
                characteristic.service.description
            )
        }
        readingConfigurationCharacteristics.remove(characteristic)

        do {
            peripheralsToReadConfigurationsFrom.remove(peripheral)
            guard error == nil else {
                cancelConnectionIfNeeded(for: peripheral)
                return
            }
            guard let value = characteristic.value else {
                throw CBATTError(.invalidPdu)
            }
            let identifier = try UUID(dataRepresentation: value)
            addNewContactEvent(with: identifier)
            cancelConnectionIfNeeded(for: peripheral)

        } catch {
            cancelConnectionIfNeeded(for: peripheral)
            os_log(
                "Processing value failed: %@",
                log: bleCentralLog,
                type: .error,
                error as CVarArg
            )
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didModifyServices invalidatedServices: [CBService]
    ) {
        os_log(
            "Peripheral (uuid=%@ name='%@') did modify services=%@",
            log: bleCentralLog,
            peripheral.identifier.description,
            peripheral.name ?? "",
            invalidatedServices
        )

        if invalidatedServices.contains(where: {
            $0.uuid == CBUUID(string: Uuids.service.uuidString)
        }) {
            peripheralsToReadConfigurationsFrom.insert(peripheral)
            cancelConnectionIfNeeded(for: peripheral)
        }
    }
}

extension TimeInterval {
    public static let peripheralConnectingTimeout: TimeInterval = 8
}
