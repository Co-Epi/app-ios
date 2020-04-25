import BackgroundTasks

class BackgroundTasksManager {

    private var tasks: [BackgroundTaskScheduler] = []

    func register(task: BackgroundTask) {
        tasks.append(BackgroundTaskScheduler(task: task))
    }

    func onApplicationFinishLaunching() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
        for task in tasks {
            task.onApplicationFinishLaunching()
        }
    }

    func applicationDidEnterBackground() {
        for task in tasks {
            task.applicationDidEnterBackground()
        }
    }
}
