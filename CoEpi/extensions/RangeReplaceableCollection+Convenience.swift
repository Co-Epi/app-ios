import Foundation

extension RangeReplaceableCollection where Element: Equatable {
    func replace(_ element: Element, with replacement: Element) -> Self {
        var mutSelf = self
        if let index = firstIndex(of: element) {
            mutSelf.replaceSubrange(index ... index, with: [replacement])
        }
        return mutSelf
    }
}
