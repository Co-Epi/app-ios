import Dip
import RxCocoa
import RxSwift
import RxSwiftExt
import os.log
import Action
import Foundation

// TODO replace with new symptoms view model
class HealthQuizViewModel: UINotifier {
    let rxQuestions: Driver<[Question]>
    let notification: Driver<UINotification>
    let setActivityIndicatorVisible: Driver<Bool>
    let submitButtonEnabled: Driver<Bool>

    let notificationSubject: PublishRelay<UINotification> = PublishRelay()

    private let symptomRepo: SymptomRepo
    private let rootNav: RootNav
    private let inputsManager: SymptomsInputManager

    private let questionsRelay: BehaviorRelay<[Question]>

    private let submitAction: CocoaAction

    let disposeBag = DisposeBag()

    init(symptomRepo: SymptomRepo, rootNav: RootNav, inputsManager: SymptomsInputManager) {
        self.symptomRepo = symptomRepo
        self.rootNav = rootNav
        self.inputsManager = inputsManager
        
        questionsRelay = BehaviorRelay(value: symptomRepo.symptoms()
            .map{ Question(symptom: $0) })

        rxQuestions = questionsRelay
            .asDriver(onErrorJustReturn: [])

        notification = notificationSubject
            .asDriver(onErrorDriveWith: .empty())

        let selectedSymptoms = questionsRelay
            .map { questions in questions
                .filter { $0.checked }
                .map { $0.toSymptom() }
            }
        submitAction = Action { [symptomRepo] in
            selectedSymptoms.map { symptoms in
                inputsManager.setSymptoms(Set(symptoms.map { $0.id } )).expect()
            }
            // TODO maybe put these 2 in extension doInBackground() or similar
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler())
        }

        setActivityIndicatorVisible = submitAction.executing
            .asDriver(onErrorJustReturn: false)

        submitButtonEnabled = Observable
            .combineLatest(selectedSymptoms, submitAction.executing) { selectedSymptoms, submitExecuting in
                !selectedSymptoms.isEmpty && !submitExecuting
            }
            .asDriver(onErrorJustReturn: false)

        bindSubmit()
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
        submitAction.execute()
    }

    private func bindSubmit() {
        submitAction.elements.subscribe(onNext: { [rootNav] _ in
            rootNav.navigate(command: .back)
        }).disposed(by: disposeBag)

        bindSuccessNotifier(submitAction.elements, message: "Symptoms submitted!")
        bindErrorNotifier(submitAction.errors)
    }
}

struct Question {
    let id: SymptomId
    let text: String
    let checked: Bool

    init(id: SymptomId, text: String, checked: Bool) {
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
