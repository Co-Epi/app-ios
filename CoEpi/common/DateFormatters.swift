import UIKit

class DateFormatters {
    static let hoursMins = HoursMinsFormatter()
    static let hoursMinsSecs = HoursMinsFormatter()
    static let month = MonthFormatter()
    static let monthDay = MonthDayFormatter()
}

final class HoursMinsFormatter: DateFormatter {
    override init() {
        super.init()

        // lowercase
        amSymbol = "am"
        pmSymbol = "pm"

        dateFormat = "h:mma"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

final class HoursMinsSecsFormatter: DateFormatter {
    override init() {
        super.init()
        dateFormat = "h:mm:ss"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

final class MonthFormatter: DateFormatter {
    override init() {
        super.init()
        dateFormat = "MMM"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

final class MonthDayFormatter: DateFormatter {
    override init() {
        super.init()
        dateFormat = "MMM d"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
