import Foundation

class NumberFormatters {
    static let tempFormatter = TemperatureFormatter()
    static let ordinal = OrdinalFormatter()
}

final class TemperatureFormatter: NumberFormatter {

    override init() {
        super.init()
        numberStyle = .none
        roundingMode = .down
        roundingIncrement = 0.0
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func string(from number: Float) -> String? {
        string(from: number as NSNumber)
    }
}

final class OrdinalFormatter: NumberFormatter {
    override init() {
        super.init()
        numberStyle = .ordinal
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
