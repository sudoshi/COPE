import XCTest

final class COPEUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchEnvironment["COPE_UI_TEST_DISABLE_SESSION_RESTORE"] = "1"
        app.launchEnvironment["COPE_API_BASE_URL"] = "http://127.0.0.1:65535"
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testUnauthenticatedLaunchShowsLoginFixture() {
        XCTAssertTrue(element("login.screen").waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["login.title"].exists)
        XCTAssertTrue(app.textFields["login.email"].exists)
        XCTAssertTrue(app.secureTextFields["login.password"].exists)
        XCTAssertTrue(app.buttons["login.sign-in.button"].exists)
    }

    func testSignInValidationStaysLocalWithoutBackend() {
        XCTAssertTrue(app.buttons["login.sign-in.button"].waitForExistence(timeout: 5))

        app.buttons["login.sign-in.button"].tap()

        XCTAssertTrue(app.staticTexts["Enter your email and password."].waitForExistence(timeout: 2))
    }

    func testRegistrationModeExposesInviteFixtureFields() {
        let registerSegment = app.segmentedControls.buttons["Register"]
        XCTAssertTrue(registerSegment.waitForExistence(timeout: 5))

        registerSegment.tap()

        XCTAssertTrue(app.textFields["register.invite-code"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.textFields["register.first-name"].exists)
        XCTAssertTrue(app.textFields["register.last-name"].exists)
        XCTAssertTrue(app.textFields["register.email"].exists)
        XCTAssertTrue(app.secureTextFields["register.password"].exists)
        XCTAssertTrue(app.secureTextFields["register.confirm-password"].exists)
        XCTAssertTrue(app.buttons["register.create-account.button"].exists)
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }
}
