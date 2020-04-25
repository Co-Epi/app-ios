class FetchAlertsBackgroundRegisterer {

    init(tasksManager: BackgroundTasksManager, coEpiRepo: CoEpiRepo) {
        tasksManager.register(task: FetchAlertsBackgroundTask(coEpiRepo: coEpiRepo))
    }
}
