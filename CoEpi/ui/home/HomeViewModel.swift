protocol HomeViewModelDelegate {
    func debugTapped()
}

class HomeViewModel  {
    var delegate: HomeViewModelDelegate?

    func debugTapped() {
        delegate?.debugTapped()
    }
}
