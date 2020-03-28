import XCTest

class OnboardingViewControllerTests: XCTestCase {

    func testButtonTitles() {
        
        let vc = OnboardingViewController(viewModel: OnboardingViewModel())
        
        XCTAssertEqual(vc.getStartedButtonTitle.string, OnboardingStrings.getStarted.uppercased())
        XCTAssertEqual(vc.privacyButtonTitle.string, OnboardingStrings.howYourDataIsUsed)
        
    }

}
