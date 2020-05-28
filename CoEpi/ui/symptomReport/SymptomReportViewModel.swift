import Dip
import RxCocoa
import RxSwift
import RxSwiftExt
import os.log
import Foundation

class SymptomReportViewModel: UINotifier {

    let notification: Driver<UINotification>

    let submitButtonEnabled: Driver<Bool>

    let notificationSubject: PublishRelay<UINotification> = PublishRelay()

    private let symptomRepo: SymptomRepo
    private let rootNav: RootNav

    private let symptomsObservable: Observable<[SymptomViewData]>

    let symptomsDriver: Driver<[SymptomViewData]>

    private let submitTrigger: PublishRelay<()> = PublishRelay()
    private let selectSymptomTrigger: PublishRelay<SymptomViewData> = PublishRelay()

    let disposeBag = DisposeBag()

    init(symptomRepo: SymptomRepo, rootNav: RootNav, symptomFlowManager: SymptomFlowManager) {
        self.symptomRepo = symptomRepo
        self.rootNav = rootNav

        notification = notificationSubject
            .asDriver(onErrorDriveWith: .empty())

        let selectedSymptomIds: BehaviorSubject<Set<SymptomId>> = BehaviorSubject(value: Set())

        symptomsObservable = Observable.combineLatest(
            Observable.just(symptomRepo.symptoms()),
            selectedSymptomIds
        ).map { symptoms, selectedIds in
            symptoms.map {
                SymptomViewData(id: $0.id, text: $0.name, checked: selectedIds.contains($0.id))
            }
        }

        let selectedSymptoms = symptomsObservable.map { symptoms in
            symptoms.filter { $0.checked }.map { $0.toSymptom() }
        }

        symptomsDriver = symptomsObservable.asDriver(onErrorJustReturn: [])

        submitTrigger.withLatestFrom(selectedSymptoms, resultSelector: {(_, symptoms) in
            symptoms.map { $0.id }
        })
        .subscribe(onNext: { symptomIds in
            if !symptomFlowManager.startFlow(symptomIds: symptomIds) {
                fatalError("Couldn't start symptom flow for: \(symptomIds)")
            }
        })
        .disposed(by: disposeBag)

        submitButtonEnabled = selectedSymptoms
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: false)

        selectSymptomTrigger
            .withLatestFrom(selectedSymptomIds, resultSelector: { selectedSymptom, selectedIds in
                selectedSymptomIds.onNext(
                    selectedIds.toggle(element: selectedSymptom.id).solveConflicts(
                        selectedId: selectedSymptom.id,
                        wasChecked: !selectedSymptom.checked)
                )
            })
            .subscribe()
            .disposed(by: disposeBag)
    }

    func onTapSubmit() {
        submitTrigger.accept(())
    }

    func onChecked(question: SymptomViewData) {
        selectSymptomTrigger.accept(question)
    }
}


extension Set {

    func toggle(element: Element) -> Set<Element> {
        if (contains(element)) {
            return filter { $0 != element }
        } else {
            return union([element])
        }
    }
}

extension Set where Element == SymptomId {
    func solveConflicts(selectedId: SymptomId, wasChecked: Bool) -> Set<Element> {
        if !wasChecked {
            return self
        } else if selectedId == .none  {
            return Set([selectedId])
        } else if contains(.none) {
            return filter { $0 != .none }
        } else {
            return self
        }
    }
}

struct SymptomViewData {
    let id: SymptomId
    let text: String
    let checked: Bool

    init(id: SymptomId, text: String, checked: Bool) {
        self.id = id
        self.text = text
        self.checked = checked
    }

    init(oldQuestion: SymptomViewData, newCheckedValue: Bool) {
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
