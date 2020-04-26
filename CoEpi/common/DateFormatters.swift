import UIKit

class DateFormatters {
    static let dateHoursMins: DateHoursMinsFormatter = DateHoursMinsFormatter()
}

final class DateHoursMinsFormatter: DateFormatter {

    override init() {
        super.init()
        dateFormat = "dd.MM.yyyy HH:mm"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
