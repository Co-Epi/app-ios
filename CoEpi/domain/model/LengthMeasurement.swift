enum LengthUnit {
    case meters, feet
}

struct Length: AutoEquatable {
    let value: Float
    let unit: LengthUnit

    func to(_ unit: LengthUnit) -> Length {
        switch (self.unit, unit) {
        case (.meters, .meters):
            return self
        case (.meters, .feet):
            return Length(value: value * 3.28084, unit: unit)
        case (.feet, .meters):
            return Length(value: value * 0.3048, unit: unit)
        case (.feet, .feet):
            return self
        }
    }
}
