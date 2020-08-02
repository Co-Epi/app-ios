import Foundation

class NumberFormatters {
    static let tempFormatter = TemperatureFormatter()
    static let oneDecimal = OneDecimalFormatter()
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

final class OneDecimalFormatter: NumberFormatter {
    override init() {
        super.init()
        roundingMode = .down
        numberStyle = .decimal
        maximumFractionDigits = 1
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func string(from number: Float) -> String? {
        string(from: number as NSNumber)
    }
}
