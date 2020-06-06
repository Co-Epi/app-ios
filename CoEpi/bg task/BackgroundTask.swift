import Foundation
import BackgroundTasks
import os.log
import RxSwift

/// Long running background task
protocol BackgroundTask {

    var identifier: String { get }

    var scheduleInterval: TimeInterval { get }
    
    func execute(task: BGProcessingTask)
}
