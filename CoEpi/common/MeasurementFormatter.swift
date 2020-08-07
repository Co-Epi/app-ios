import Foundation

protocol LengthFormatter {
    func format(length: Length) -> String
}

struct LengthFormatterImpl: LengthFormatter {
    func format(length: Length) -> String {
        guard let formattedNumber = NumberFormatters.oneDecimal.string(from: length.value) else {
            fatalError("Couldn't format length: \(length)")
        }
        switch length.unit {
        case .meters: return L10n.Units.meters(formattedNumber)
        case .feet: return L10n.Units.feet(formattedNumber)
        }
    }
}
