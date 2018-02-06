//
//  taipeiparkTests.swift
//  taipeiparkTests
//
//  Created by 楊德忻 on 2018/2/3.
//  Copyright © 2018年 sean. All rights reserved.
//

import XCTest
@testable import taipeipark

class taipeiparkTests: XCTestCase {
    
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
    
    func testRequestParkInfo() {
        let expectation = self.expectation(description: "Expectation")
        ParkDataManager.sharedManager.requestParkInfo { (datas, success) in
            XCTAssert(success, "api issue")
            XCTAssert(datas != nil)
            XCTAssert(datas!.count > 0)
            for key in datas!.keys {
                for data in datas![key]! {
                    XCTAssert(data.parkName != nil && !data.parkName.isEmpty)
                    XCTAssert(data.introduction != nil, "introduction: \(data.introduction!)")
                }
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 30) { (exp) in
            
        }
    }
    
    func testParseResults() {
        // !!!:must after testRequestParkInfo.
        XCTAssertTrue(ParkDataManager.sharedManager.parseResults(rawString: UserDefaults.standard.string(forKey: KEY)))
        XCTAssertFalse(ParkDataManager.sharedManager.parseResults(rawString: ""))
    }
    
}
