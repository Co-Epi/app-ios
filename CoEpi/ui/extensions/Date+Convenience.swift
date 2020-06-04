import Foundation

extension Date {

    // Special formatting to add "th" to the day.
    // TODO test with non-EN langs. Probably needs to differentiate based on locale.
    func formatMonthOrdinalDay() -> String {
        let day = Calendar.current.component(.day, from: self)
        let dayOrdinal = NumberFormatters.ordinal.string(from: NSNumber(value: day))!
        let month = DateFormatters.month.string(from: self)
        return "\(month) \(dayOrdinal)"
    }
}
