import Foundation

let cachingLog = CachingLog()
let log: Log = CompositeLog(
    logs: cachingLog, ConsoleLog()
)

class CompositeLog: Log {
    private let logs: [LogNonVariadicTags]

    init(logs: LogNonVariadicTags...) {
        self.logs = logs
        for log in logs {
            log.setup()
        }
    }

    func setup() {
        for log in logs {
            log.setup()
        }
    }

    func v(_ message: String, tags: LogTag...) {
        for log in logs {
            log.v(message, tags: tags)
        }
    }

    func d(_ message: String, tags: LogTag...) {
        for log in logs {
            log.d(message, tags: tags)
        }
    }

    func i(_ message: String, tags: LogTag...) {
        for log in logs {
            log.i(message, tags: tags)
        }
    }

    func w(_ message: String, tags: LogTag...) {
        for log in logs {
            log.w(message, tags: tags)
        }
    }

    func e(_ message: String, tags: LogTag...) {
        for log in logs {
            log.e(message, tags: tags)
        }
    }
}
