import Foundation
import os.log

let bleLog = OSLog(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "ble"
)

let servicesLog = OSLog(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "services"
)

let networkingLog = OSLog(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "networking"
)
