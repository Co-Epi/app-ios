class FetchAlertsBackgroundRegisterer {

    init(tasksManager: BackgroundTasksManager, coEpiRepo: CoEpiRepo) {
        // Disabled until properly tested / completed.
        tasksManager.register(task: FetchAlertsBackgroundTask(coEpiRepo: coEpiRepo))
    }
}
