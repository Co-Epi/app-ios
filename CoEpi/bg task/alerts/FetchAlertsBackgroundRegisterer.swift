class FetchAlertsBackgroundRegisterer {

    init(tasksManager: BackgroundTasksManager, alertRepo: AlertRepo) {
        tasksManager.register(task: FetchAlertsBackgroundTask(alertRepo: alertRepo))
    }
}
