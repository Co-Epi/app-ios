import Foundation
import RxSwift

protocol UnitsFormatter {
    var formatter: Observable<MeasurementFormatter> { get }
}

class UnitsFormatterImpl: UnitsFormatter {
    private let localeProvider: LocaleProvider

    let formatter: Observable<MeasurementFormatter>

    init(localeProvider: LocaleProvider) {
        self.localeProvider = localeProvider

        formatter = localeProvider.locale.map {
            let formatter = MeasurementFormatter()
            formatter.locale = $0
            return formatter
        }
    }
}
