import Foundation

extension Array where Element: Equatable {

    func distinct() -> [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }

    func deleteFirst(element: Element) -> [Element] {
        guard let index = firstIndex(of: element) else { return self }
        var mutSelf = self
        mutSelf.remove(at: index)
        return mutSelf
    }
}
