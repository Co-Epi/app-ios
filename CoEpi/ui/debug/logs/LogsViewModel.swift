import Foundation
import RxCocoa
import RxSwift
import UIKit

class LogsViewModel {
    let logsObservable: Observable<[LogMessageViewData]>
    let logs: Driver<[LogMessageViewData]>

    let notificationSubject: PublishRelay<UINotification> = PublishRelay()
    let notification: Driver<UINotification>

    let clipboard: Clipboard
    let envInfos: EnvInfos

    private let longTapTrigger: PublishSubject<Void> = PublishSubject()

    private let disposeBag = DisposeBag()

    init(log: CachingLog, clipboard: Clipboard, envInfos: EnvInfos) {
        self.clipboard = clipboard
        self.envInfos = envInfos

        logsObservable = log.logs
            .map { $0.array }
            .map { $0.map { $0.toViewData() } }

        logs = logsObservable
            .asDriver(onErrorJustReturn: [])

        notificationSubject.accept(.success(message: "Logs copied to clipboard"))

        notification = notificationSubject
            .asDriver(
                onErrorJustReturn: UINotification.error(
                    message: "Unknown error with notification"))

        longTapTrigger.withLatestFrom(logsObservable)
            .map { logViewData in
                let logs = logViewData.map { $0.message }
                return "\(envInfos.clipboardString())\n\n\(logs.toClipboardText())"
            }
            .subscribe(onNext: { [weak self] text in
                self?.notififyTextCopied(text: text)
            }).disposed(by: disposeBag)
    }

    func notififyTextCopied(text: String) {
        clipboard.putInClipboard(text: text)
        notificationSubject.accept(.success(message: "Logs copied to clipboard"))
    }

    func onLongPress() {
        longTapTrigger.onNext(())
    }
}

struct LogMessageViewData {
    let time: String
    let text: String
    let textColor: UIColor
    let message: LogMessage
}

private extension LogMessage {
    func toViewData() -> LogMessageViewData {
        LogMessageViewData(time: DateFormatters.hoursMinsSecs.string(from: time),
                           text: text,
                           textColor: level.color(),
                           message: self)
    }
}

private extension LogLevel {
    func color() -> UIColor {
        switch self {
        case .v: return .black
        case .d: return UIColor(hex: "228C22")
        case .i: return .blue
        case .w: return .orange
        case .e: return .red
        }
    }

    func text() -> String {
        switch self {
        case .v: return "V"
        case .d: return "D"
        case .i: return "I"
        case .w: return "W"
        case .e: return "E"
        }
    }
}

private extension Array where Element == LogMessage {
    func toClipboardText() -> String {
        map { logMessage in
            DateFormatters
                .hoursMinsSecs
                .string(from: logMessage.time)
                + " " + logMessage.level.text()
                + " " + logMessage.text
        }.joined(separator: "\n")
    }
}

private extension EnvInfos {
    func clipboardString() -> String {
        "App version: \(appVersionName) (\(appVersionCode)), " +
            "Device: \(deviceName), " +
            "iOS version: \(osVersion)"
    }
}
