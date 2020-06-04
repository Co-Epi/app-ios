import Foundation

class NumberFormatters {
    static let decimalsMax2 = Number2MaxDecimalsFormatter()
    static let ordinal = OrdinalFormatter()
}

final class Number2MaxDecimalsFormatter: NumberFormatter {

    override init() {
        super.init()
        numberStyle = .decimal
        minimumFractionDigits = 0
        maximumFractionDigits = 2
        roundingMode = .halfUp
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
