//
//  DateUtils.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2016-06-02.
//  Copyright © 2016 Morrdusk. All rights reserved.
//

import Foundation

enum Weekday: String {
    case Sunday
    case Monday
}

class DateUtils {

    func firstDayOfWeek() -> Weekday {
        let calendar = Calendar.current
        return firstDayOfWeek(calendar.firstWeekday)
    }

    func firstDayOfWeek(_ firstWeekday: Int) -> Weekday {
        return (firstWeekday == 7) ? Weekday.Sunday : Weekday.Monday
    }

    func daysFromStartOfWeekForFirstOfMonth(_ date: Date) -> Int? {
        if let firstDay = getDateOfFirstDayInMonth(date) {
            return daysFromStartOfWeek(firstDayOfWeek(), date: firstDay)
        }
        
        return nil
    }

    func getWeekdaySymbols() -> [String] {
        return getWeekdaySymbols(firstDayOfWeek())
    }

    func getWeekdaySymbols(_ firstDayOfWeek: Weekday) -> [String] {
        var symbols = DateFormatter().veryShortStandaloneWeekdaySymbols // -> ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let firstWeekday = (firstDayOfWeek == Weekday.Sunday) ? 1 : 2
        return Array(symbols![firstWeekday-1..<symbols!.count]) + symbols![0..<firstWeekday-1]
    }

    /**
     * Calculates the number of days from the start of the week for the given date.
     *
     * This handles the case that weeks can start both on Sunday and on Mondays based on locale.
     *
     * Note, first day = 1, last day of week = 7
     */
    func daysFromStartOfWeek(_ firstDayOfWeek: Weekday, date: Date) -> Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.weekday], from: date)

        return daysFromStartOfWeek(firstDayOfWeek, dayOfWeek: components.weekday!)
    }

    func daysFromStartOfWeek(_ firstDayOfWeek: Weekday, dayOfWeek: Int) -> Int {
        if firstDayOfWeek == Weekday.Sunday {
            return dayOfWeek - 1
        }
        else {
            let rem = (dayOfWeek - 2) % 7
            return rem < 0 ? rem + 7 : rem // swift modulo operator doesn't work with negative numbers so handle that
        }
    }
    
    func noDaysInMonth(_ date: Date) -> Int? {
        let calendar = Calendar.current
        if let startOfMonth = getDateOfFirstDayInMonth(date) {
            // get the number of days in the month
            return (calendar as NSCalendar).range(of: .day, in: .month, for: startOfMonth).length
        }
        else {
            return nil
        }
    }

    func monthAndYear(_ date: Date, locale: Locale=Locale.current) -> String {
        let dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMM yyyy", options: 0, locale: locale)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }

    fileprivate func getDateOfFirstDayInMonth(_ date: Date) -> Date? {
        let calendar = Calendar.current
        // get the month and year date components from the supplied date
        let components = (calendar as NSCalendar).components([.year, .month], from: date)
        // get the date of the first day of the month
        return calendar.date(from: components)
    }

}
