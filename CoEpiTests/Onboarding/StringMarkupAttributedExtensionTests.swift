import XCTest

class StringMarkupAttributedExtensionTests: XCTestCase {

    func testStringAsExpected() {
        
        let markup = "<b>Track</b> where you've been"
        
        XCTAssertEqual(markup.markupAttributed(pointSize: 14, color: .red).string, "Track where you've been")
        
    }

}
