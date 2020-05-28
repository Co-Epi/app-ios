////not sure how?

//import Foundation
//
//
//class SymptomInputsInitalizer {
//    func selectSymptomIds(ids: Set<SymptomId>)
//}
//
//class SymptomInputsProps {
//    var inputs: SymptomInputs
//    func setCoughType(type: UserInput<Cough.Type>)
//    func setCoughDays(days: UserInput<Cough.Days>)
//    func setCoughStatus(status: UserInput<Cough.Status>)
//    func setBreathlessnessCause(cause: UserInput<Breathlessness.Cause>)
//    func setFeverDays(days: UserInput<Fever.Days>)
//    func setFeverTakenTemperatureToday(taken: UserInput<Boolean>)
//    func setFeverTakenTemperatureSpot(spot: UserInput<Fever.TemperatureSpot>)
//    func setFeverHighestTemperatureTaken(temp: UserInput<Temperature>)
//    func setEarliestSymptom(days: UserInput<EarliestSymptom.Days>)
//}
//
//class SymptomInputsManager : SymptomInputsInitalizer, SymptomInputsProps {
//    func clear()
//}
//
//
//class SymptomInputsManagerImpl :
//    SymptomInputsManager {
//    override var inputs: SymptomInputs =
//        SymptomInputs()
//        //private set   //not sure what this does
//
//    override func selectSymptomIds(ids: Set<SymptomId>) {
//        inputs = initInputs(ids).copy(ids = ids)
//    }
//
//    private func initInputs(ids: Set<SymptomId>): SymptomInputs =
//        ids.fold(SymptomInputs()) { acc, e ->
//            when (e) {
//                COUGH -> acc.copy(cough = Cough())
//                BREATHLESSNESS -> acc.copy(breathlessness = Breathlessness())
//                FEVER -> acc.copy(fever = Fever())
//                EARLIESTSYMPTOM -> acc.copy(earliestSymptomDate = EarliestSymptom())
//                else -> {
//                    log.i("TODO handle inputs: $e")
//                    acc
//                }
//            }
//        }
//
//    override func setCoughType(type: UserInput<Cough.Type>) {
//        if (!inputs.ids.contains(COUGH)) {error("Cough not set")}
//        inputs = inputs.copy(cough = inputs.cough.copy(type = type))
//    }
//
//    override func setCoughDays(days: UserInput<Cough.Days>) {
//        if (!inputs.ids.contains(COUGH)) {error("Cough not set")}
//        inputs = inputs.copy(cough = inputs.cough.copy(days = days))
//    }
//
//    override func setCoughStatus(status: UserInput<Cough.Status>) {
//        if (!inputs.ids.contains(COUGH)) {error("Cough not set")}
//        inputs = inputs.copy(cough = inputs.cough.copy(status = status))
//    }
//
//    override func setBreathlessnessCause(cause: UserInput<Breathlessness.Cause>) {
//        if (!inputs.ids.contains(BREATHLESSNESS)) {error("Breathlessness not set")}
//        inputs = inputs.copy(breathlessness = inputs.breathlessness.copy(cause = cause))
//    }
//
//    override func setFeverDays(days: UserInput<Fever.Days>) {
//        if (!inputs.ids.contains(FEVER)) {error("Fever not set")}
//        inputs = inputs.copy(fever = inputs.fever.copy(days = days))
//    }
//
//    override func setFeverTakenTemperatureToday(taken: UserInput<Boolean>) {
//        if (!inputs.ids.contains(FEVER)) {error("Fever not set")}
//        inputs = inputs.copy(fever = inputs.fever.copy(takenTemperatureToday = taken))
//    }
//
//    override func setFeverTakenTemperatureSpot(spot: UserInput<Fever.TemperatureSpot>) {
//        if (!inputs.ids.contains(FEVER)) {error("Fever not set")}
//        inputs = inputs.copy(fever = inputs.fever.copy(temperatureSpot = spot))
//    }
//
//    override func setFeverHighestTemperatureTaken(temp: UserInput<Temperature>) {
//        if (!inputs.ids.contains(FEVER)){ error("Fever not set")}
//        inputs = inputs.copy(fever = inputs.fever.copy(highestTemperature = temp))
//    }
//
//    override func setEarliestSymptom(days: UserInput<EarliestSymptom.Days>) {
//        //There's no need to check if the ID's contain EARLIESTSYMPTOM because
//        //earliest symptom needs to get checked no matter what (kinda like thanks screen)
//        inputs = inputs.copy(earliestSymptomDate = inputs.earliestSymptomDate.copy(days = days))
//    }
//
//    override func clear() {
//        inputs = SymptomInputs()
//    }
//}
