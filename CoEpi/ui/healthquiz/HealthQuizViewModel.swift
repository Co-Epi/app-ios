import Dip
import RxCocoa
import RxSwift
import os.log

class HealthQuizViewModel {
    weak var delegate: HealthQuizViewModelDelegate?

    private let symptomRepo: SymptomRepo
    private let questionsRelay: BehaviorRelay<[Question]>

    private(set) var rxQuestions: Driver<[Question]>

    private let submitTrigger: PublishRelay<Void> = PublishRelay()

    private let disposeBag = DisposeBag()

    init(container: DependencyContainer) {
        self.symptomRepo = try! container.resolve()
        questionsRelay = BehaviorRelay(value: symptomRepo.symptoms()
            .map{ Question(symptom: $0) })

        rxQuestions = questionsRelay
            .asDriver(onErrorJustReturn: [])

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
            .flatMap { [symptomRepo] (symptoms: [Symptom]) in
                symptomRepo.submitSymptoms(symptoms: symptoms).andThen(Observable.just(()))
            }
            .subscribe(onNext: { [weak self] in
                self?.delegate?.onSubmit()
            }, onError: { error in
                os_log("Error submitting symptoms: %@", type: .error, "\(error)")
            })
            .disposed(by: disposeBag)
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
