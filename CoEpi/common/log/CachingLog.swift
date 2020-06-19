import RxSwift
import Foundation

struct LimitedSizeQueue<T> {
    public private(set) var array: [T] = []

    private let maxSize: Int

    init(maxSize: Int) {
        self.maxSize = maxSize
    }

    public mutating func add(value: T) {
        array.append(value)

        if array.count > maxSize {
            array.removeSubrange(0..<(array.count - maxSize - 1))
        }
    }

    public var isEmpty: Bool { return array.isEmpty }
}

class CachingLog: LogNonVariadicTags {

    let logs = BehaviorSubject(value: LimitedSizeQueue<LogMessage>(maxSize: 1000))

    private let addLogTrigger: PublishSubject<LogMessage> = PublishSubject()
    private let disposeBag = DisposeBag()

    init() {
        addLogTrigger.withLatestFrom(logs, resultSelector: {(message, logs) in
            (message, logs)
        })
        .subscribe(onNext: { [weak self] (message, logs) in
            var mut = logs
            mut.add(value: message)
            self?.logs.onNext(mut)
        }).disposed(by: disposeBag)
    }

    func setup() {}

    func v(_ message: String, tags: [LogTag]) {
        log(LogMessage(level: .v, text: addTag(tags: tags, message: message)))
    }

    func d(_ message: String, tags: [LogTag]) {
        log(LogMessage(level: .d, text: addTag(tags: tags, message: message)))
    }

    func i(_ message: String, tags: [LogTag]) {
        log(LogMessage(level: .i, text: addTag(tags: tags, message: message)))
    }

    func w(_ message: String, tags: [LogTag]) {
        log(LogMessage(level: .w, text: addTag(tags: tags, message: message)))
    }

    func e(_ message: String, tags: [LogTag]) {
        log(LogMessage(level: .e, text: addTag(tags: tags, message: message)))
    }

    private func log(_ message: LogMessage) {
        addLogTrigger.onNext(message)
    }

    private func addTag(tags: [LogTag], message: String) -> String {
        let tagsStr = tags.map { "[\($0)]"}.joined(separator: " ")
        let tagPart = tagsStr.isEmpty ? "" : tagsStr + " "
        return tagPart + message
    }
}

struct LogMessage {
    let level: LogLevel
    let text: String
    let time: Date = Date()
}
