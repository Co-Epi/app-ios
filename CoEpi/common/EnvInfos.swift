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

//
// private func getVersionNumber() -> String{
//
//    guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
//     else{
//        fatalError("Failed to read bundle version")
//    }
//    print("Version : \(version)");
//    return "\(L10n.Ux.Home.Footer.version): \(version)"
// }
//
// private func getBuildNumber() -> String {
//    guard let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
//        fatalError("Failed to read build number")
//    }
//    print("Build : \(build)")
//    return "\(L10n.Ux.Home.Footer.build): \(build)"
// }
