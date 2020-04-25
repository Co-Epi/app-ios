import UIKit
import RxSwift
import RxCocoa
import os.log

protocol StartPermissions {
    var granted: Observable<Bool> { get }

    func request()
}

class StartPermissionsImpl: StartPermissions {
    let granted: Observable<Bool>

    private let grantedSubject: PublishRelay<Bool> = PublishRelay()

    init() {
        granted = grantedSubject.asObservable()
    }

    func request() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if let error = error {
                os_log("Error requesting permission: %@", log: servicesLog, type: .debug, "\(error)")
            }
            self.grantedSubject.accept(granted)
        }
    }
}
