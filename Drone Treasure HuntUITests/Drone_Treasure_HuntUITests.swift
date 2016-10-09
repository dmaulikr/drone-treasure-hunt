//
//  Drone_Treasure_HuntUITests.swift
//  Drone Treasure HuntUITests
//
//  Created by Massimo Donati on 10/6/16.
//  Copyright © 2016 Massimo Donati. All rights reserved.
//

import XCTest

class Drone_Treasure_HuntUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInfiniteHunt() {
        
        let app = XCUIApplication()
        let startButton = app.alerts.buttons["Start"]
        let newHuntButton = app.alerts["Win!!!!"].buttons["New hunt"]

        infiniteTest(startButton: startButton, newHuntButton: newHuntButton)
    }

    func infiniteTest(startButton: XCUIElement, newHuntButton: XCUIElement) {
        let exists = NSPredicate(format: "exists == 1")

        expectation(for: exists, evaluatedWith: startButton, handler: nil)

        waitForExpectations(timeout: 4) { (error) in
            startButton.tap()
        }


        expectation(for: exists, evaluatedWith: newHuntButton, handler: nil)

        waitForExpectations(timeout: 20) { (error) in
            newHuntButton.tap()
        }

        infiniteTest(startButton: startButton, newHuntButton: newHuntButton)
    }

}
