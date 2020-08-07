import Foundation
import RxSwift

protocol UnitsProvider {
    var temperatureUnit: Observable<UnitTemperature> { get }
    var lengthUnit: Observable<LengthUnit> { get }
}

class UnitsProviderImpl: UnitsProvider {
    private let localeProvider: LocaleProvider

    var temperatureUnit: Observable<UnitTemperature>
    var lengthUnit: Observable<LengthUnit>

    init(localeProvider: LocaleProvider) {
        self.localeProvider = localeProvider

        temperatureUnit = localeProvider.locale.map {
            deriveTemperatureUnit(locale: $0)
        }

        lengthUnit = localeProvider.locale.map {
            deriveMeasureUnit(locale: $0)
        }
    }
}

private func deriveTemperatureUnit(locale: Locale) -> UnitTemperature {
    // Not ideal. Apple doesn't seem to provide an api to get directly the unit
    // https://stackoverflow.com/a/52997665/930450

    // TODO it seems we should implement our own unit system:
    // - It's not possible to tune the granularity of Apple's units (e.g. inches/feet)
    //   -> This point was solved with LengthMeasurementUnit. Do the same for temperature.
    // - Need this workaround to get the locale's temperature
    // - Technically can get Kelvin temperature unit

    let formatter = MeasurementFormatter()
    formatter.locale = locale

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

private func deriveMeasureUnit(locale: Locale) -> LengthUnit {
    let countryCode = locale.regionCode ?? {
        log.e("No region code in locale: defaulting to US", tags: .locale)
        // The app will be tested and probably launched initially here
        return "US"
    }()

    switch countryCode {
    case "US", "LR", "MM": return .feet
    default: return .meters
    }
}
