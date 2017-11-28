//
//  AnimeManagerTests.swift
//  AnimeManagerTests
//
//  Created by Lucy Zhang on 11/28/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import XCTest
import os.log
@testable import AnimeManager

class AnimeManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMAL(){
        let expect = expectation(description: "MAL List")
        MyAnimeList.sharedInstance.getAnimeList(username: "Silent_Muse", completion: { (data) in
            expect.fulfill()
        }) { (error) in
            print(error)
            expect.fulfill()
        }
        waitForExpectations(timeout: 100) { (error) in
            os_log("Failed HTTP Request with error: %@", error.debugDescription)
        }
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
