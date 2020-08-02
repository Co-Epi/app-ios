import XCTest

class FFIStandaloneTests: XCTestCase {
    func testLoggerSetup() {
        // First call will set the log level to 0/Trace. Remaining calls will have no effect.
        for i: Int32 in 0 ... 4 {
            loggerSetupWithLevel(levelInt: i)
        }
    }

    func loggerSetupWithLevel(levelInt: Int32) {
        let level = CoreLogLevel(levelInt)
        print("iOS : Logger level : \(level)")
        let ret = setup_logger(level, false)
        /*
         fn from_usize(u: usize) -> Option<LevelFilter> {
             match u {
                 0 => Some(LevelFilter::Off),
                 1 => Some(LevelFilter::Error),
                 2 => Some(LevelFilter::Warn),
                 3 => Some(LevelFilter::Info),
                 4 => Some(LevelFilter::Debug),
                 5 => Some(LevelFilter::Trace),
                 _ => None,
             }
         }
         */
        XCTAssertEqual(5, ret)
    }
}
