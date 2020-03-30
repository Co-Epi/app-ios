protocol AlertRepo {
    func alerts() -> [Alert]
}

class AlertRepoImpl: AlertRepo {
    let alertData: [Alert] = [
        Alert(id: "a", exposure: "testa"),
        Alert(id: "b", exposure: "testb"),
        Alert(id: "c", exposure: "testc"),
        Alert(id: "d", exposure: "testd"),
    ]

    func alerts() -> [Alert] {
        alertData
    }
}
