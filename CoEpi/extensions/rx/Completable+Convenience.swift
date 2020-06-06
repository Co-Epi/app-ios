import Foundation
import RxSwift

extension Completable {

    func asVoidObservable() -> Observable<Void> {
        andThen(.just(()))
    }

    func materialize() -> Observable<Event<Void>> {
        asVoidObservable().materialize()
    }
}
