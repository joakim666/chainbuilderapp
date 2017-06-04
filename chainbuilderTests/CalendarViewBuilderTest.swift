//
// Created by Joakim Ek on 2016-06-08.
// Copyright (c) 2016 Morrdusk. All rights reserved.
//

import XCTest
@testable import chainbuilder_dev

class CalendarViewBuilderTest: XCTestCase {

    let builder = CalendarViewBuilder()

    func testBuildFor20160309() {
        var c = DateComponents()
        c.day = 9
        c.month = 2
        c.year = 2016

        let calendar = Calendar.current
        let date20160209 = calendar.date(from: c)!

        guard let rows = builder.createRows(date20160209, today: date20160209, chainsToShow: []) else {
            XCTFail()
            return
        }

        // header row
        XCTAssertEqual("M", rows[0].days[0].label?.text)
        XCTAssertEqual("T", rows[0].days[1].label?.text)
        XCTAssertEqual("W", rows[0].days[2].label?.text)
        XCTAssertEqual("T", rows[0].days[3].label?.text)
        XCTAssertEqual("F", rows[0].days[4].label?.text)
        XCTAssertEqual("S", rows[0].days[5].label?.text)
        XCTAssertEqual("S", rows[0].days[6].label?.text)
        
        // week 1
        XCTAssertEqual("1", rows[1].days[0].label?.text)
        XCTAssertEqual("2", rows[1].days[1].label?.text)
        XCTAssertEqual("3", rows[1].days[2].label?.text)
        XCTAssertEqual("4", rows[1].days[3].label?.text)
        XCTAssertEqual("5", rows[1].days[4].label?.text)
        XCTAssertEqual("6", rows[1].days[5].label?.text)
        XCTAssertEqual("7", rows[1].days[6].label?.text)

        // week 2
        XCTAssertEqual("8", rows[2].days[0].label?.text)
        XCTAssertEqual("9", rows[2].days[1].label?.text)
        XCTAssertEqual("10", rows[2].days[2].label?.text)
        XCTAssertEqual("11", rows[2].days[3].label?.text)
        XCTAssertEqual("12", rows[2].days[4].label?.text)
        XCTAssertEqual("13", rows[2].days[5].label?.text)
        XCTAssertEqual("14", rows[2].days[6].label?.text)

        // week 3
        XCTAssertEqual("15", rows[3].days[0].label?.text)
        XCTAssertEqual("16", rows[3].days[1].label?.text)
        XCTAssertEqual("17", rows[3].days[2].label?.text)
        XCTAssertEqual("18", rows[3].days[3].label?.text)
        XCTAssertEqual("19", rows[3].days[4].label?.text)
        XCTAssertEqual("20", rows[3].days[5].label?.text)
        XCTAssertEqual("21", rows[3].days[6].label?.text)

        // week 4
        XCTAssertEqual("22", rows[4].days[0].label?.text)
        XCTAssertEqual("23", rows[4].days[1].label?.text)
        XCTAssertEqual("24", rows[4].days[2].label?.text)
        XCTAssertEqual("25", rows[4].days[3].label?.text)
        XCTAssertEqual("26", rows[4].days[4].label?.text)
        XCTAssertEqual("27", rows[4].days[5].label?.text)
        XCTAssertEqual("28", rows[4].days[6].label?.text)

        // week 5
        XCTAssertEqual("29", rows[5].days[0].label?.text)
        XCTAssertNil(rows[5].days[1].label?.text)
        XCTAssertNil(rows[5].days[2].label?.text)
        XCTAssertNil(rows[5].days[3].label?.text)
        XCTAssertNil(rows[5].days[4].label?.text)
        XCTAssertNil(rows[5].days[5].label?.text)
        XCTAssertNil(rows[5].days[6].label?.text)
    }

    func testBuildFor20160325() {
        var c = DateComponents()
        c.day = 25
        c.month = 3
        c.year = 2016

        let calendar = Calendar.current
        let date20160325 = calendar.date(from: c)!

        guard let rows = builder.createRows(date20160325, today: date20160325, chainsToShow: []) else {
            XCTFail()
            return
        }

        // header row
        XCTAssertEqual("M", rows[0].days[0].label?.text)
        XCTAssertEqual("T", rows[0].days[1].label?.text)
        XCTAssertEqual("W", rows[0].days[2].label?.text)
        XCTAssertEqual("T", rows[0].days[3].label?.text)
        XCTAssertEqual("F", rows[0].days[4].label?.text)
        XCTAssertEqual("S", rows[0].days[5].label?.text)
        XCTAssertEqual("S", rows[0].days[6].label?.text)

        // week 1
        XCTAssertNil(rows[1].days[0].label?.text)
        XCTAssertEqual("1", rows[1].days[1].label?.text)
        XCTAssertEqual("2", rows[1].days[2].label?.text)
        XCTAssertEqual("3", rows[1].days[3].label?.text)
        XCTAssertEqual("4", rows[1].days[4].label?.text)
        XCTAssertEqual("5", rows[1].days[5].label?.text)
        XCTAssertEqual("6", rows[1].days[6].label?.text)

        // week 2
        XCTAssertEqual("7", rows[2].days[0].label?.text)
        XCTAssertEqual("8", rows[2].days[1].label?.text)
        XCTAssertEqual("9", rows[2].days[2].label?.text)
        XCTAssertEqual("10", rows[2].days[3].label?.text)
        XCTAssertEqual("11", rows[2].days[4].label?.text)
        XCTAssertEqual("12", rows[2].days[5].label?.text)
        XCTAssertEqual("13", rows[2].days[6].label?.text)

        // week 3
        XCTAssertEqual("14", rows[3].days[0].label?.text)
        XCTAssertEqual("15", rows[3].days[1].label?.text)
        XCTAssertEqual("16", rows[3].days[2].label?.text)
        XCTAssertEqual("17", rows[3].days[3].label?.text)
        XCTAssertEqual("18", rows[3].days[4].label?.text)
        XCTAssertEqual("19", rows[3].days[5].label?.text)
        XCTAssertEqual("20", rows[3].days[6].label?.text)

        // week 4
        XCTAssertEqual("21", rows[4].days[0].label?.text)
        XCTAssertEqual("22", rows[4].days[1].label?.text)
        XCTAssertEqual("23", rows[4].days[2].label?.text)
        XCTAssertEqual("24", rows[4].days[3].label?.text)
        XCTAssertEqual("25", rows[4].days[4].label?.text)
        XCTAssertEqual("26", rows[4].days[5].label?.text)
        XCTAssertEqual("27", rows[4].days[6].label?.text)

        // week 5
        XCTAssertEqual("28", rows[5].days[0].label?.text)
        XCTAssertEqual("29", rows[5].days[1].label?.text)
        XCTAssertEqual("30", rows[5].days[2].label?.text)
        XCTAssertEqual("31", rows[5].days[3].label?.text)
        XCTAssertNil(rows[5].days[4].label?.text)
        XCTAssertNil(rows[5].days[5].label?.text)
        XCTAssertNil(rows[5].days[6].label?.text)
    }

    func testBuildFor20160505() {
        var c = DateComponents()
        c.day = 5
        c.month = 5
        c.year = 2016

        let calendar = Calendar.current
        let date20160505 = calendar.date(from: c)!

        guard let rows = builder.createRows(date20160505, today: date20160505, chainsToShow: []) else {
            XCTFail()
            return
        }

        // header row
        XCTAssertEqual("M", rows[0].days[0].label?.text)
        XCTAssertEqual("T", rows[0].days[1].label?.text)
        XCTAssertEqual("W", rows[0].days[2].label?.text)
        XCTAssertEqual("T", rows[0].days[3].label?.text)
        XCTAssertEqual("F", rows[0].days[4].label?.text)
        XCTAssertEqual("S", rows[0].days[5].label?.text)
        XCTAssertEqual("S", rows[0].days[6].label?.text)

        // week 1
        XCTAssertNil(rows[1].days[0].label?.text)
        XCTAssertNil(rows[1].days[1].label?.text)
        XCTAssertNil(rows[1].days[2].label?.text)
        XCTAssertNil(rows[1].days[3].label?.text)
        XCTAssertNil(rows[1].days[4].label?.text)
        XCTAssertNil(rows[1].days[5].label?.text)
        XCTAssertEqual("1", rows[1].days[6].label?.text)

        // week 2
        XCTAssertEqual("2", rows[2].days[0].label?.text)
        XCTAssertEqual("3", rows[2].days[1].label?.text)
        XCTAssertEqual("4", rows[2].days[2].label?.text)
        XCTAssertEqual("5", rows[2].days[3].label?.text)
        XCTAssertEqual("6", rows[2].days[4].label?.text)
        XCTAssertEqual("7", rows[2].days[5].label?.text)
        XCTAssertEqual("8", rows[2].days[6].label?.text)

        // week 3
        XCTAssertEqual("9", rows[3].days[0].label?.text)
        XCTAssertEqual("10", rows[3].days[1].label?.text)
        XCTAssertEqual("11", rows[3].days[2].label?.text)
        XCTAssertEqual("12", rows[3].days[3].label?.text)
        XCTAssertEqual("13", rows[3].days[4].label?.text)
        XCTAssertEqual("14", rows[3].days[5].label?.text)
        XCTAssertEqual("15", rows[3].days[6].label?.text)

        // week 4
        XCTAssertEqual("16", rows[4].days[0].label?.text)
        XCTAssertEqual("17", rows[4].days[1].label?.text)
        XCTAssertEqual("18", rows[4].days[2].label?.text)
        XCTAssertEqual("19", rows[4].days[3].label?.text)
        XCTAssertEqual("20", rows[4].days[4].label?.text)
        XCTAssertEqual("21", rows[4].days[5].label?.text)
        XCTAssertEqual("22", rows[4].days[6].label?.text)

        // week 5
        XCTAssertEqual("23", rows[5].days[0].label?.text)
        XCTAssertEqual("24", rows[5].days[1].label?.text)
        XCTAssertEqual("25", rows[5].days[2].label?.text)
        XCTAssertEqual("26", rows[5].days[3].label?.text)
        XCTAssertEqual("27", rows[5].days[4].label?.text)
        XCTAssertEqual("28", rows[5].days[5].label?.text)
        XCTAssertEqual("29", rows[5].days[6].label?.text)

        // week 6
        XCTAssertEqual("30", rows[6].days[0].label?.text)
        XCTAssertEqual("31", rows[6].days[1].label?.text)
        XCTAssertNil(rows[6].days[2].label?.text)
        XCTAssertNil(rows[6].days[3].label?.text)
        XCTAssertNil(rows[6].days[4].label?.text)
        XCTAssertNil(rows[6].days[5].label?.text)
        XCTAssertNil(rows[6].days[6].label?.text)
    }
}
