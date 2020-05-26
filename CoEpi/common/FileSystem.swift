import Foundation

protocol FileSystem {
    func coreDatabasePath() -> Result<String, ServicesError>
}

class FileSystemImpl: FileSystem {

    func coreDatabasePath() -> Result<String, ServicesError> {
        documentsFolderPath().map { url in
            let foo = url.appendingPathComponent("core").path
            print("foo: \(foo)")
            return url.appendingPathComponent("core").path
        }
    }

    private func documentsFolderPath() -> Result<URL, ServicesError> {
        do {
            return .success(try FileManager.default.url(
                for: FileManager.SearchPathDirectory.documentDirectory,
                in: FileManager.SearchPathDomainMask.userDomainMask,
                appropriateFor: nil,
                create: true
            ))
        } catch (let e) {
            return .failure(ServicesError.error(message: "Couldn't get documents path: \(e)"))
        }
    }
}
