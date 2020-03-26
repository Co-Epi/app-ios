protocol HomeViewModelDelegate {
    func debugTapped()
    func quizTapped()
}

class HomeViewModel  {
    var delegate: HomeViewModelDelegate?
    
    let title = "CoEpi"

    func debugTapped() {
        delegate?.debugTapped()
    }
    
    func quizTapped() {
        delegate?.quizTapped()
    }
}
