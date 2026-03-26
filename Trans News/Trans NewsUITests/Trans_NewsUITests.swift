//
//  Trans_NewsUITests.swift
//  Trans NewsUITests
//
//  Created by Bintang Nadi Maulana on 22/03/26.
//

import XCTest

final class Trans_NewsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UITEST_SKIP_ONBOARDING")
        app.launch()

        XCTAssertTrue(app.buttons["Kategori"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Profil"].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launchArguments.append("UITEST_SKIP_ONBOARDING")
            app.launch()
        }
    }
}
