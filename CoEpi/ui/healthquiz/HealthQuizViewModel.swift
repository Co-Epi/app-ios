import Dip
import RxCocoa
import RxSwift
import os.log

class HealthQuizViewModel {
    let rxQuestions: Driver<[Question]>
    let notification: Driver<UINotification>

    private let notificationSubject: PublishRelay<UINotification> = PublishRelay()

    weak var delegate: HealthQuizViewModelDelegate?

    private let symptomRepo: SymptomRepo
    private let questionsRelay: BehaviorRelay<[Question]>

    private let submitTrigger: PublishRelay<Void> = PublishRelay()

    private let disposeBag = DisposeBag()

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

        submitTrigger.withLatestFrom(selectedSymptoms)
            .flatMap { [symptomRepo, notificationSubject] symptoms in
                Self.submitSymptoms(symptomRepo: symptomRepo, symptoms: symptoms, notificationSubject: notificationSubject)
            }
            .subscribe(onNext: { [weak self] success in
                if success {
                    self?.delegate?.onSubmit()
                    self?.notificationSubject.accept(.success(message: "Symptoms submitted!"))
                }
            }, onError: { error in
                os_log("Error submitting symptoms: %@", type: .error, "\(error)")
            })
            .disposed(by: disposeBag)
    }

    private static func submitSymptoms(symptomRepo: SymptomRepo, symptoms: [Symptom],
                                       notificationSubject: PublishRelay<UINotification>) -> Observable<Bool> {
        symptomRepo.submitSymptoms(symptoms: symptoms)
            .do(onError: { [notificationSubject] error in
                notificationSubject.accept(.error(message: "\(error)"))
            })
            .andThen(.just(true))
            .catchErrorJustReturn(false)
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
