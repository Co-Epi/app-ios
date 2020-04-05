import RxSwift
import RxCocoa

protocol UINotifier {
    var notificationSubject: PublishRelay<UINotification> { get }
    var notification: Driver<UINotification> { get }
    var disposeBag: DisposeBag { get }
}

extension UINotifier {

    func bindSuccessErrorNotifier<T>(_ obs: Observable<Event<T>>, successMessage: String) {
        bindSuccessNotifier(obs.elements(), message: successMessage)
        bindErrorNotifier(obs.errors())
    }

    func bindSuccessNotifier<T>(_ obs: Observable<T>, message: String) {
        obs.subscribe { [notificationSubject] error in
            notificationSubject.accept(.success(message: message))
        }.disposed(by: disposeBag)
    }

    func bindErrorNotifier<T: Error>(_ obs: Observable<T>) {
        obs.subscribe { [notificationSubject] error in
            notificationSubject.accept(.error(message: "\(error)"))
        }.disposed(by: disposeBag)
    }
}
