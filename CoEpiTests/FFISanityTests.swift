@testable import CoEpi
import XCTest

// See note in test
var expectationWorkaroundGlobal: XCTestExpectation?

class FFISanityTests: XCTestCase {
    func testSendStruct() {
        let strPointer: UnsafePointer<Int8>? = NSString(string: "hi from iOS").utf8String
        var myStruct = FFIParameterStruct(
            my_int: 123,
            my_str: strPointer,
            my_nested: FFINestedParameterStruct(my_u8: 250)
        )
        let pointer = withUnsafeMutablePointer(to: &myStruct) {
            UnsafeMutablePointer<FFIParameterStruct>($0)
        }
        let value = pass_struct(pointer)
        XCTAssertEqual(value, 1)
    }

    func testReceiveStruct() {
        let returnedStruct = return_struct()
        XCTAssertEqual(returnedStruct.my_int, 123)

        let unmanagedString: Unmanaged<CFString> = returnedStruct.my_str
        let cfStr: CFString = unmanagedString.takeRetainedValue()
        let str = cfStr as String

        XCTAssertEqual(str, "hi!")
        XCTAssertEqual(returnedStruct.my_nested.my_u8, 255)
    }

    func testSendAndReceiveStruct() {
        let str = "hi from iOS"
        let strPointer: UnsafePointer<Int8>? = NSString(string: str).utf8String
        var myStruct = FFIParameterStruct(
            my_int: 123,
            my_str: strPointer,
            my_nested: FFINestedParameterStruct(my_u8: 250)
        )
        let pointer = withUnsafeMutablePointer(to: &myStruct) {
            UnsafeMutablePointer<FFIParameterStruct>($0)
        }
        let returnedStruct = pass_and_return_struct(pointer)
        XCTAssertEqual(returnedStruct.my_int, myStruct.my_int)

        let unmanagedString: Unmanaged<CFString> = returnedStruct.my_str
        let cfStr: CFString = unmanagedString.takeRetainedValue()
        let returnedStr = cfStr as String

        XCTAssertEqual(returnedStr, str)
        XCTAssertEqual(returnedStruct.my_nested.my_u8, myStruct.my_nested.my_u8)
    }

    func testCallback() {
        let ret = call_callback { myInt, myBool, myCFString in
            // TODO: why CFString? here while in the struct it's Unmanaged<CFString>
            let cfStr: CFString = myCFString!
            let str = cfStr as String

            XCTAssertEqual(myInt, 123)
            XCTAssertEqual(myBool, false)
            XCTAssertEqual(str, "hi!")
        }
        XCTAssertEqual(ret, 1)
    }

    func testRegisterCallback() {
        expectationWorkaroundGlobal = expectation(description: #function)

        let ret = register_callback { myInt, myBool, myCFString in
            // TODO: why CFString? here while in the struct it's Unmanaged<CFString>
            let cfStr: CFString = myCFString!
            let str = cfStr as String

            // The first 2 parameters are hardcoded in Rust
            XCTAssertEqual(myInt, 1)
            XCTAssertEqual(myBool, true)

            // This is what we send here
            XCTAssertEqual(str, "hi from iOS")

            // NOTE: MAJOR WORKAROUND: for:
            // "A C function pointer cannot be formed from a closure that captures context"
            // It only accepts global variables.
            // There's a better workaround IIRC, but more complex. For now letting it like this.
            // TODO: better workaround.
            expectationWorkaroundGlobal?.fulfill()
        }
        XCTAssertEqual(ret, 1)

        let triggerRet = trigger_callback("hi from iOS")
        XCTAssertEqual(triggerRet, 1)

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testRegisterCallbackForStructuredLogging() {
        let ret = register_log_callback { logMessage in
            logToiOS(logMessage: logMessage)
        }
        XCTAssertEqual(ret, 2)
        let x = trigger_logging_macros()
        XCTAssertEqual(x, 1)
        sleep(1)
    }
}
