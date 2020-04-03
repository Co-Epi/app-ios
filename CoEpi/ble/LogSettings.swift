import Foundation
import os.log

let bleCentralLog = OSLog(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "BLECentral"
)

let blePeripheralLog = OSLog(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "BLEPeripheral"
)

let servicesLog = OSLog(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "services"
)
