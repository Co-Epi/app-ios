import Foundation
import RxSwift

protocol LocaleProvider {
    var locale: Observable<Locale> { get }
    func update()
}

class LocaleProviderImpl: LocaleProvider {
    private let localeSubject: BehaviorSubject<Locale> =
        BehaviorSubject(value: getLocale())

    lazy var locale = localeSubject
        .asObservable()
        .distinctUntilChanged()

    init() {
        update()
    }

    private static func getLocale() -> Locale {
        Bundle.main.preferredLocalizations
            .first.map { Locale(identifier: $0) } ?? Locale(identifier: "en")
    }

    func update() {
        let locale = LocaleProviderImpl.getLocale()
        log.d("Updating locale: \(locale)")
        localeSubject.onNext(locale)
    }
}
