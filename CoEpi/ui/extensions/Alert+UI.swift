extension Alert {
    var durationForUI: ExposureDurationForUI {
        switch durationSeconds {
        case _ where durationSeconds >= secondsInHour:
            let (hours, mins) = secondsToHoursMinutes(seconds: durationSeconds)
            return .hoursMinutes(hours, mins)
        case _ where durationSeconds >= secondsInMinute:
            return .minutes(durationSeconds / secondsInMinute)
        default:
            return .seconds(durationSeconds)
        }
    }
}

enum ExposureDurationForUI {
    case seconds(Int)
    case minutes(Int)
    case hoursMinutes(Int, Int)
}

private func secondsToHoursMinutes(seconds: Int) -> (Int, Int) {
    (seconds / secondsInHour, (seconds % secondsInHour) / secondsInMinute)
}

private let secondsInHour = 3600
private let secondsInMinute = 60
