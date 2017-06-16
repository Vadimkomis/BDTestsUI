//
//  BDTestsUITestsUITests.swift
//  BDTestsUITestsUITests
//
//  Created by Derek Bronston on 5/22/17.
//  Copyright © 2017 Derek Bronston. All rights reserved.
//

import XCTest


class BDTestsUITestsUITests: BDTestsUI {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for eac
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTextfield() {
        
        //EXISTS, ENTER TEXT
        self.textfield(identifier: "test-text-field", text: "text",exists: true)
        self.textfield(identifier: "no-test-text-field", text: "text",exists: false)
    }
    
    func testSecureTextfield() {
        
        //EXISTS, ENTER TEXT
       // self.textfield(identifier: "test-text-field", text: "text")
    }
    
}
