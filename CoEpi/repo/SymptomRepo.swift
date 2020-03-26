import Foundation

protocol SymptomRepo {
    func symptoms() -> [Symptom]

    func submitSymptoms(symptoms: [Symptom])
}

class SymptomRepoImpl: SymptomRepo {

    func symptoms() -> [Symptom] {
        [
            Symptom(id: "1", name: "Fever"),
            Symptom(id: "2", name: "Tiredness"),
            Symptom(id: "3", name: "Loss of appetite"),
            Symptom(id: "4", name: "Muscle aches"),
            Symptom(id: "5", name: "Trouble breathing"),
            Symptom(id: "6", name: "Nasal congestion"),
            Symptom(id: "7", name: "Sneezing"),
            Symptom(id: "8", name: "Sore throat"),
            Symptom(id: "9", name: "Headaches"),
            Symptom(id: "10", name: "Diarrhea"),
            Symptom(id: "11", name: "Loss of smell or taste")
        ]
    }

    func submitSymptoms(symptoms: [Symptom]) {
        // Send to api
    }
}
