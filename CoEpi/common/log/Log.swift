enum LogTag {
    case db, ui, core
}

protocol Log {
    func setup()
    func v(_ message: String, tags: LogTag...)
    func d(_ message: String, tags: LogTag...)
    func i(_ message: String, tags: LogTag...)
    func w(_ message: String, tags: LogTag...)
    func e(_ message: String, tags: LogTag...)
}

// Workaround: Swift doesn't support yet passing varargs to another varargs parameter
protocol LogNonVariadicTags {
    func setup()
    func v(_ message: String, tags: [LogTag])
    func d(_ message: String, tags: [LogTag])
    func i(_ message: String, tags: [LogTag])
    func w(_ message: String, tags: [LogTag])
    func e(_ message: String, tags: [LogTag])
}

enum LogLevel {
    case v
    case d
    case i
    case w
    case e
}
