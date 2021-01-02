//
//  EachDayTests.swift
//  EachDayTests
//
//  Created by Eleanor Peng on 2020/12/31.
//

import XCTest
@testable import EachDay

class EachDayTests: XCTestCase {

    var sut: TimeTrackingSummaryViewController!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = TimeTrackingSummaryViewController()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        sut = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func timeSpentPercentageComputed() {
        let timeValues: [Double] = [12, 35, 60, 180, 42, 37]
        let percentageValues = [3.3, 9.6, 16.4, 49.2, 11.5, 10.1]
        sut.computePieChartValue(time: timeValues)
        XCTAssertEqual(sut.percentageTimeValues, percentageValues, "Percentage computed from computePieChartValue is incorrect.")
    }

}
