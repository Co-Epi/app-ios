import RxCocoa
import RxSwift
import UIKit

class SymptomReportViewController: UIViewController, ErrorDisplayer {
    private let viewModel: SymptomReportViewModel
    private let dataSource: HealthQuizQuestionsDataSource = .init()

    @IBOutlet var symptomQuestionHeader: UILabel!
    @IBOutlet var subHeader: UILabel!
    @IBOutlet var questionList: UITableView!
    @IBOutlet var submitButton: UIButton!

    private let disposeBag = DisposeBag()

    init(viewModel: SymptomReportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
        title = L10n.Ux.SymptomReport.heading

        dataSource.onChecked = { question in
            viewModel.onChecked(question: question)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func share() {
        Sharer().share(viewController: self, completion: { [weak self] in
            self?.viewModel.onTapSubmit()
        })
    }

    @IBAction func submit(_: UIButton) {
        viewModel.onTapSubmit()
    }

    override func viewDidLoad() {
        questionList.register(cellClass: SymptomReportCell.self)

        viewModel.symptomsDriver
            .drive(questionList.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        viewModel.notification
            .drive(rx.notification)
            .disposed(by: disposeBag)

        viewModel.submitButtonEnabled
            .drive(submitButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.submitButtonEnabled
            .map { $0 ? .coEpiPurple : .lightGray }
            .drive(submitButton.rx.backgroundColor)
            .disposed(by: disposeBag)

        viewModel.setActivityIndicatorVisible
            .drive(view.rx.setActivityIndicatorVisible())
            .disposed(by: disposeBag)

        symptomQuestionHeader.text = L10n.Ux.SymptomReport.title
        subHeader.text = L10n.Ux.SymptomReport.subtitle
        submitButton.setTitle(L10n.Ux.submit, for: .normal)
        ViewStyles.applyRoundedEnds(to: submitButton)
        ViewStyles.applyShadows(to: submitButton)
    }
}

class HealthQuizQuestionsDataSource: NSObject, RxTableViewDataSourceType {
    private var questions: [SymptomViewData] = []

    public var onChecked: ((SymptomViewData) -> Void)?

    func tableView(_ tableView: UITableView, observedEvent: RxSwift.Event<[SymptomViewData]>) {
        if case let .next(questions) = observedEvent {
            self.questions = questions
            tableView.reloadData()
        }
    }
}

extension HealthQuizQuestionsDataSource: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        questions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SymptomReportCell = tableView.dequeue(
            cellClass: SymptomReportCell.self,
            forIndexPath: indexPath
        )

        let question: SymptomViewData = questions[indexPath.row]
        cell.setQuestion(question: question)

        cell.onChecked = { [weak self] question in
            self?.onChecked?(question)
        }

        return cell
    }
}
