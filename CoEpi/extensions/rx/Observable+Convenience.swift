import Foundation
import RxSwift

extension ObservableType {

    func asSequence() -> Observable<[Element]> {
        scan([]) { acc, element in acc + [element] }.startWith([])
    }
}
