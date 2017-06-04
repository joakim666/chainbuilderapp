//
//  chainbuilderTests.swift
//  chainbuilderTests
//
//  Created by Joakim Ek on 2016-05-31.
//  Copyright © 2016 Morrdusk. All rights reserved.
//

/* NOTE chainbuilder_dev below, it's due to
 * "all dashes will be converted to underscores so at the top of your test files, you'll have to add @testable import Foo_Bar."
 */

import XCTest
@testable import chainbuilder_dev

class chainbuilderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
