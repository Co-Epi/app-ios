import Foundation

struct BTContact {
    private let theirData: Data?
    private let ourData: Data?

    init(theirData: Data?, ourData: Data?) {
        self.theirData = theirData
        self.ourData = ourData
    }

    var theirIdentifier: String {
        return decodeData(data: theirData) ?? ""
    }

    var ourIdentifier: String {
        return decodeData(data: ourData) ?? ""
    }

    private func decodeData(data: Data?) -> String? {
        guard let value = data else { return nil }
        return value.compactMap { String(format: "%02x", $0) }.joined()
    }
}
