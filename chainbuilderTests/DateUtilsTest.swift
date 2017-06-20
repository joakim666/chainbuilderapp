//
//  DateUtilsTest.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2016-06-02.
//  Copyright © 2016 Morrdusk. All rights reserved.
//

import Nimble
import XCTest
@testable import chainbuilder_dev

class DateUtilsTests: XCTestCase {

    let dateUtils = DateUtils()


    func testGetWeekdaySymbols() {
        var symbols = dateUtils.getWeekdaySymbols(Weekday.Sunday)
        expect(symbols).to(equal(["S", "M", "T", "W", "T", "F", "S"]))

        symbols = dateUtils.getWeekdaySymbols(Weekday.Monday)
        expect(symbols).to(equal(["M", "T", "W", "T", "F", "S", "S"]))
    }

    func testDaysFromStartOfWeek() {
        expect(self.dateUtils.daysFromStartOfWeek(Weekday.Sunday, dayOfWeek: 1)).to(equal(0)) // sunday
        expect(self.dateUtils.daysFromStartOfWeek(Weekday.Sunday, dayOfWeek: 2)).to(equal(1)) // monday
        expect(self.dateUtils.daysFromStartOfWeek(Weekday.Sunday, dayOfWeek: 3)).to(equal(2)) // tuesday
        expect(self.dateUtils.daysFromStartOfWeek(Weekday.Sunday, dayOfWeek: 4)).to(equal(3)) // wednesday
        expect(self.dateUtils.daysFromStartOfWeek(Weekday.Sunday, dayOfWeek: 5)).to(equal(4)) // thursday
        expect(self.dateUtils.daysFromStartOfWeek(Weekday.Sunday, dayOfWeek: 6)).to(equal(5)) // friday
        expect(self.dateUtils.daysFromStartOfWeek(Weekday.Sunday, dayOfWeek: 7)).to(equal(6)) // saturday

        expect(self.dateUtils.daysFromStartOfWeek(Weekday.Monday, dayOfWeek: 1)).to(equal(6)) // sunday
        expect(self.dateUtils.daysFromStartOfWeek(Weekday.Monday, dayOfWeek: 2)).to(equal(0)) // monday
        expect(self.dateUtils.daysFromStartOfWeek(Weekday.Monday, dayOfWeek: 3)).to(equal(1)) // tuesday
        expect(self.dateUtils.daysFromStartOfWeek(Weekday.Monday, dayOfWeek: 4)).to(equal(2)) // wednesday
        expect(self.dateUtils.daysFromStartOfWeek(Weekday.Monday, dayOfWeek: 5)).to(equal(3)) // thursday
        expect(self.dateUtils.daysFromStartOfWeek(Weekday.Monday, dayOfWeek: 6)).to(equal(4)) // friday
        expect(self.dateUtils.daysFromStartOfWeek(Weekday.Monday, dayOfWeek: 7)).to(equal(5)) // saturday
    }

    func testDaysFromStartOfWeek2() {
        let date20160101 = DateUtilsTests.makeNSDate(2016, month: 1, day: 1)

        expect(self.dateUtils.daysFromStartOfWeek(Weekday.Monday, date: date20160101)).to(equal(4))
        expect(self.dateUtils.daysFromStartOfWeek(Weekday.Sunday, date: date20160101)).to(equal(5))
    }

    func testGetMonthAndYear() {
        let date20160101 = DateUtilsTests.makeNSDate(2016, month: 1, day: 1)

        expect(self.dateUtils.monthAndYear(date20160101, locale: Locale(identifier: "en_US"))).to(equal("January 2016"))
    }

    // --- Helper methods below

    static func makeNSDate(_ year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar.current

        var c = DateComponents()
        c.year = year
        c.month = month
        c.day = day

        return calendar.date(from: c)!
    }

}
