import UIKit

class EnvInfos {

    var deviceName: String {
        UIDevice.current.name
    }

    var appVersionName: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    var appVersionCode: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    var osVersion: String {
        UIDevice.current.systemVersion
    }
}
