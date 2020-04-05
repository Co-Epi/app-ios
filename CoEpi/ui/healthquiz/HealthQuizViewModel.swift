import Dip
import RxCocoa
import RxSwift
import RxSwiftExt
import os.log

class HealthQuizViewModel: UINotifier {
    let rxQuestions: Driver<[Question]>
    let notification: Driver<UINotification>

    let notificationSubject: PublishRelay<UINotification> = PublishRelay()

    weak var delegate: HealthQuizViewModelDelegate?

    private let symptomRepo: SymptomRepo
    private let questionsRelay: BehaviorRelay<[Question]>

    private let submitTrigger: PublishRelay<Void> = PublishRelay()

    let disposeBag = DisposeBag()

    init(container: DependencyContainer) {
        self.symptomRepo = try! container.resolve()
        questionsRelay = BehaviorRelay(value: symptomRepo.symptoms()
            .map{ Question(symptom: $0) })

        rxQuestions = questionsRelay
            .asDriver(onErrorJustReturn: [])

        notification = notificationSubject
            .asDriver(onErrorDriveWith: .empty())

        observeSubmit()
    }

    func question(at index: Int) -> Question {
        return questionsRelay.value[index]
    }

    func handleAnswer(question: Question, idx: Int) {
        var newQuestions = questionsRelay.value
        newQuestions[idx] = question
        questionsRelay.accept(newQuestions)
    }

    func onTapSubmit() {
        submitTrigger.accept(())
    }

    private func observeSubmit() {
        let selectedSymptoms = questionsRelay
            .map { questions in questions
                .filter { $0.checked }
                .map { $0.toSymptom() }
            }

        let events: Observable<Event<()>> = submitTrigger.withLatestFrom(selectedSymptoms)
            .flatMap { [symptomRepo] symptoms in
                symptomRepo.submitSymptoms(symptoms: symptoms)
                    .materialize()
            }
            .share()

        events.elements().subscribe(onNext: { [weak self] success in
            self?.delegate?.onSubmit()
        }).disposed(by: disposeBag)

        bindSuccessErrorNotifier(events, successMessage: "Symptoms submitted!")
    }
}

struct Question {
    let id: String
    let text: String
    let checked: Bool

    init(id: String, text: String, checked: Bool) {
        self.id = id
        self.text = text
        self.checked = checked
    }

    init(oldQuestion: Question, newCheckedValue: Bool) {
        self.id = oldQuestion.id
        self.text = oldQuestion.text
        self.checked = newCheckedValue
    }

    init(symptom: Symptom) {
        self.id = symptom.id
        self.text = symptom.name
        self.checked = false
    }

    func toSymptom() -> Symptom {
        return Symptom(id: id, name: text)
    }
}

protocol HealthQuizViewModelDelegate: class {
    func onSubmit()
}
