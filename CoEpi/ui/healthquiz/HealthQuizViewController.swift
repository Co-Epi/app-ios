import UIKit
import RxSwift
import RxCocoa

class HealthQuizViewController: UIViewController, ErrorDisplayer {
    private let viewModel: HealthQuizViewModel
    private let dataSource: HealthQuizQuestionsDataSource = .init()

    @IBOutlet weak var questionList: UITableView!
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: HealthQuizViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
        title = "My Health"
        
        dataSource.onChecked = { (question, idx) in
            viewModel.handleAnswer(question: question, idx: idx)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func share() {
        Sharer().share(viewController: self, completion: { [weak self] in
            self?.viewModel.onTapSubmit()
        })
    }

    private func showAlert() {
        ConfirmationAlert().show(on: self,
                                 title: "Thank you for reporting your symptoms",
                                 message: "Please share this app so we can stop the spread of Covid-19",
                                 yesText: "Share",
                                 noText: "Don't Share",
                                 yesAction: { [weak self] in
                                    self?.share()
                                 },
                                 noAction: { [weak self] in
                                    self?.viewModel.onTapSubmit()
                                 })
    }
    
    @IBAction func submit(_ sender: UIButton) {
        showAlert()
    }

    override func viewDidLoad() {
        questionList.register(cellClass: QuestionCell.self)

        viewModel.rxQuestions
            .drive(questionList.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        viewModel.notification
            .drive(rx.notification)
            .disposed(by: disposeBag)
     }
}

class HealthQuizQuestionsDataSource: NSObject, RxTableViewDataSourceType {
    private var questions: [Question] = []

    public var onChecked: ((Question, Int) -> ())?

    func tableView(_ tableView: UITableView, observedEvent: RxSwift.Event<[Question]>) {
        if case let .next(questions) = observedEvent {
            self.questions = questions
            tableView.reloadData()
        }
    }
}

extension HealthQuizQuestionsDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        questions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeue(cellClass: QuestionCell.self, forIndexPath: indexPath)
        guard let questionCell = cell as? QuestionCell else { return cell }
        
        let question: Question = questions[indexPath.row]
        questionCell.setQuestion(question: question)

        questionCell.onChecked = { [weak self] (question, checked) in
            guard let this = self,
                let idx = this.questions.firstIndex(where: { $0.id == question.id }) else { return }

            this.questions[idx] = Question(oldQuestion: this.questions[idx], newCheckedValue: checked)

            this.onChecked?(this.questions[idx], idx)
        }

        return questionCell
    }
}
