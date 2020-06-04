import UIKit

class DateFormatters {
    static let dateHoursMins = DateHoursMinsFormatter()
    static let month = MonthFormatter()
}

final class DateHoursMinsFormatter: DateFormatter {

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


final class MonthFormatter: DateFormatter {

    override init() {
        super.init()
        dateFormat = "MMM"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
