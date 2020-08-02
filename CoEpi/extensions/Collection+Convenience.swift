extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    func groupByOrdered<T: Hashable>(key: (Element) -> (T)) -> [(T, [Element])] {
        var groups: [T: [Element]] = [:]
        var groupsOrder: [T] = []

        for element in self {
            let key = key(element)

            if case nil = groups[key]?.append(element) {
                groups[key] = [element]
                groupsOrder.append(key)
            }
        }

        return groupsOrder.map { ($0, groups[$0] ?? []) }
    }
}
