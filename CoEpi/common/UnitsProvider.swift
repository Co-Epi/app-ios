import Foundation
import RxSwift

protocol UnitsProvider {
    var temperatureUnit: Observable<UnitTemperature> { get }
    var formatter: Observable<MeasurementFormatter> { get }
}

class UnitsProviderImpl: UnitsProvider {
    private let localeProvider: LocaleProvider

    var temperatureUnit: Observable<UnitTemperature>
    let formatter: Observable<MeasurementFormatter>

    init(localeProvider: LocaleProvider) {
        self.localeProvider = localeProvider

        temperatureUnit = localeProvider.locale.map {
            determineTemperatureUnit(locale: $0)
        }

        formatter = localeProvider.locale.map {
            createFormatter(locale: $0)
        }
    }
}

private func createFormatter(locale: Locale) -> MeasurementFormatter {
    let formatter = MeasurementFormatter()
    formatter.locale = locale
    return formatter
}

private func determineTemperatureUnit(locale: Locale) -> UnitTemperature {
    // Not ideal. Apple doesn't seem to provide an api to get directly the unit
    // https://stackoverflow.com/a/52997665/930450

    // TODO it seems we should implement our own unit system:
    // - It's not possible to tune the granularity of Apple's units (e.g. inches/feet)
    // - Need this workaround to get the locale's temperature
    // - Technically can get Kelvin temperature unit

    let formatter = createFormatter(locale: locale)
    let measurement = Measurement(value: 0, unit: UnitTemperature.celsius)
    let output = formatter.string(from: measurement)
    if output.contains("C") {
        return .celsius
    } else if output.contains("F") {
        return .fahrenheit
    } else {
        fatalError("Unexpected temperature string: \(output)")
    }
}
