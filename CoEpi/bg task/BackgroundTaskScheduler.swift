import UIKit
import BackgroundTasks

/// Registers and schedules background processing tasks
class BackgroundTaskScheduler {

    private let task: BackgroundTask

    init(task: BackgroundTask) {
        self.task = task
    }

    func onApplicationFinishLaunching() {
        register(taskIdentifier: task.identifier)
    }

    func applicationDidEnterBackground() {
        schedule(delay: task.scheduleInterval)
    }

    private func register(taskIdentifier: String) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            self.handleTask(task: task as! BGProcessingTask)
        }
    }

    private func handleTask(task: BGProcessingTask) {
        log.d("handleTask: \(task)")

        schedule(delay: self.task.scheduleInterval)

        self.task.execute(task: task)

        task.expirationHandler = {
            task.setTaskCompleted(success: false)
            log.d("Background task expired")
        }
    }

    private func schedule(delay: TimeInterval) {
        log.d("Scheduling BG task. Delay: \(delay)")

        let request = BGProcessingTaskRequest(identifier: task.identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: delay)
        do {
          // NOTE: This has to be called on a bg thread if used while app is launched.
          // Not needed if used when app is send to bg.
          // TODO flag to use bg thread. Or maybe just use always thread.
          try BGTaskScheduler.shared.submit(request)
        } catch let e {
            log.e("Unable to submit task: \(request), error: \(e)")
        }
    }
}
