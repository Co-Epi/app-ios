import UIKit

class DateFormatters {
    static let dateHoursMins: DateHoursMinsFormatter = DateHoursMinsFormatter()
}

final class DateHoursMinsFormatter: DateFormatter {

    override init() {
        super.init()
        dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
