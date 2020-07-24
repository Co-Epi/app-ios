import UIKit
import CoreData
import Dip
import AppCenter
import AppCenterDistribute

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let container: DependencyContainer = Dependencies().createContainer()

    internal var window: UIWindow?

    private var rootWireframe: RootWireFrame?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
        -> Bool {
        MSAppCenter.start("2581ac81-eb5b-423a-83e6-65cab9d64dd8", withServices: [MSDistribute.self])

        let bgManager: BackgroundTasksManager = try! container.resolve()
        bgManager.onApplicationFinishLaunching()

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        let bgManager: BackgroundTasksManager = try! container.resolve()
        bgManager.applicationDidEnterBackground()
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions)
        -> UISceneConfiguration {
        UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role)
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "CoEpi")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
//                fatalError()
//                Replace this implementation with code to handle the error appropriately.
//                causes the application to generate a crash log and terminate.
//                You should not use this function in a shipping application,
//                although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
