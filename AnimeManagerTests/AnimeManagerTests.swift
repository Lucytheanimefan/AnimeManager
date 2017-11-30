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
    
//    func testMAL(){
//        let expect = expectation(description: "MAL List")
//        let aniList = MyAnimeList(username: "Silent_Muse", password: nil)
//        aniList.getAnimeList(status: .all, completion: { (data) in
//            expect.fulfill()
//        }) { (error) in
//            print(error)
//            //expect.fulfill()
//        }
//        waitForExpectations(timeout: 10) { (error) in
//            os_log("Failed HTTP Request with error: %@", error.debugDescription)
//        }
//    }
//
//    func testDroppedShows(){
//        let expect = expectation(description: "MAL List")
//        let aniList = MyAnimeList(username: "Silent_Muse", password: nil)
//        aniList.getAnimeList(status: .dropped, completion: { (data) in
//            expect.fulfill()
//            print("DROPPED")
//            //print(data)
//        }) { (error) in
//            print(error)
//            //expect.fulfill()
//        }
//        waitForExpectations(timeout: 10) { (error) in
//            os_log("Failed HTTP Request with error: %@", error.debugDescription)
//        }
//    }
    
//    func testSearchMAL(){
//        let expect = expectation(description: "MAL Search")
//        let aniList = MyAnimeList(username: "Silent_Muse", password: "")
//        aniList.searchMAL(query: "full metal") { (data) in
//            expect.fulfill()
//        }
//        waitForExpectations(timeout: 10) { (error) in
//            os_log("Failed HTTP Request with error: %@", error.debugDescription)
//        }
//    }
//
//    func testFunimationLogin(){
//        let expect = expectation(description: "Funi Auth")
//        let funi = Funimation.init()
//        funi.authenticate(username: "spothorse9.lucy@gmail.com", password: "Pink9999!", completion: {(data) in
//
//            expect.fulfill()
//            }
//        )
//
//        waitForExpectations(timeout: 20) { (error) in
//            os_log("Failed HTTP Request with error: %@", error.debugDescription)
//        }
//    }

//    func testKitsu(){
//        let expect = expectation(description: "Kitsu Auth")
//        Kitsu().search(attribute: "text", value: "tokyo ghoul", completion: {(data) in
//            //os_log("%@: Result: %@", self.description, data)
//            expect.fulfill()
//        })
//
//        waitForExpectations(timeout: 20) { (error) in
//            os_log("Failed HTTP Request with error: %@", error.debugDescription)
//        }
//    }
    
//    func testCRLogin(){
//        let expect = expectation(description: "CR Auth")
//        CrunchyRoll().login(username: "lucy.7a11@gmail.com", password: "", completion: {(data) in
//            os_log("%@: Result: %@", self.description, data)
//            expect.fulfill()
//        })
//
//        waitForExpectations(timeout: 10) { (error) in
//            os_log("Failed HTTP Request with error: %@", error.debugDescription)
//        }
//    }
    
    func testANNAllArticles(){
        let expect = expectation(description: "ANN Articles")
        AnimeNewsNetwork.sharedInstance.allArticles { (articles) in
            os_log("%@: Article: %@", self.description, articles)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 60) { (error) in
            os_log("Failed HTTP Request with error: %@", error.debugDescription)
        }
    }
    
}
