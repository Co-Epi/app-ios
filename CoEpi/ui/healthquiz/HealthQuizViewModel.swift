import Dip
import RxCocoa

class HealthQuizViewModel {
    weak var delegate: HealthQuizViewModelDelegate?

    private let symptomRepo: SymptomRepo

    private var questions: [Question]
    
    private(set) var rxQuestions: Driver<[Question]>
    
    init(container: DependencyContainer) {
        self.symptomRepo = try! container.resolve()
        questions = symptomRepo.symptoms().map{ Question(symptom: $0) }

        rxQuestions = BehaviorRelay(value: questions)
            .asDriver(onErrorJustReturn: [])
    }

    func question(at index: Int) -> Question {
        return questions[index]
    }

    func handleAnswer(question: Question, idx: Int) {
        questions[idx] = question
    }

    func onTapSubmit() {
        let selectedSymptoms = questions
            .filter { $0.checked }
            .map { $0.toSymptom() }
        symptomRepo.submitSymptoms(symptoms: selectedSymptoms)
        delegate?.onSubmit()
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
