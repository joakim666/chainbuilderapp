//
// Created by Joakim Ek on 2016-06-04.
// Copyright (c) 2016 Morrdusk. All rights reserved.
//

import UIKit
import Neon


// Represents one row in the calendar table
class CalendarRow {
    let container = UIView()
    var days = [DayView]() // not fileprivate so it can be unit tested

    func layout() {
        container.groupAndFill(group: .horizontal, views: days.map{$0}, padding: 0)

        for d in days {
            d.layout()
        }
    }
}

// Represents one day in one row in the calendar table
class DayView : UIView {
    var label: UILabel?
    var marks: [UIView]?
    let tappedCallback: (() -> Void)?

    init(_ tappedCallback: @escaping () -> Void) {
        self.tappedCallback = tappedCallback
        super.init(frame: CGRect.zero)

        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(DayView.handlePress(gestureReconizer:)))
        recognizer.minimumPressDuration = 0.7 // long press on days to register tap
        addGestureRecognizer(recognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.tappedCallback = nil
        super.init(coder: aDecoder)
    }
    
    func handlePress(gestureReconizer: UILongPressGestureRecognizer) {
        guard gestureReconizer.state == UIGestureRecognizerState.began else {
            return
        }
        if let tappedCallback = self.tappedCallback {
            tappedCallback()
        }
    }
    
    func layout() {
        if let label = self.label {
            label.fillSuperview()
        }

        if let marks = self.marks {
            self.groupAndFill(group: .vertical, views: marks, padding: 0)
        }
    }

    func addLabel(_ str: String, bgColor: UIColor=UIColor.white, fgColor: UIColor=UIColor.black) {
        let l: UILabel = UILabel()
        l.backgroundColor = bgColor
        l.text = str
        l.textAlignment = .center
        l.font = UIFont.boldSystemFont(ofSize: 20)
        l.textColor = fgColor
        self.insertSubview(l, at: 0)
        self.label = l
    }
    
    /**
     This shows this day as having been "executed", i.e. it's been tapped on at some point in time
 
     This version of this method is used when showing an overview of multiple chains. I.e. showing the
     the marked days from more than one chain
     
     - parameters:
        - color:    The color to use for the mark
        - position: The position vertically to show this mark
        - total:    The total number of chains to show marks for
    */
    func tick(_ color: UIColor, position: Int, total: Int) {
        let v = UIView()
        v.backgroundColor = color
        v.alpha = 0.75
        
        if self.marks == nil {
            self.marks = [UIView]()
            for _ in 0..<total {
                let mark = UIView()
                mark.alpha = 0
                self.addSubview(mark)
                self.marks?.append(mark)
            }
        }
        
        self.marks![position].removeFromSuperview()
        self.marks![position] = v
        self.addSubview(v)
    }

}

class CalendarViewBuilder {

    let dateUtils = DateUtils()

    var dayPressedCallback: ((_:Date) -> Void)?
    
    /**
     Create the rows for a calendar month with the given date.
     
     - returns:
     An array of the created rows.
     
     - parameters:
        - date:  The date for the month to show. Can not be empty.
        - today: The today date so that day can be highlighted
        - chainsToShow: a tuple array containing the chains to show, zero or more chains are supported
            - dates: The dates that have been selected, i.e. tapped on earlier. Can not be empty but can be an empty array.
            - color: The color to use when highlightning the selected days.
    */
    func createRows(_ date: Date, today: Date, chainsToShow: [(dates: [Date], color: String)]) -> [CalendarRow]? {
        guard let startWeekday = dateUtils.daysFromStartOfWeekForFirstOfMonth(date) else {
            log.error("Failed to determine starting weekday for date \(date)")
            return nil
        }
        guard let noDaysInMonth = dateUtils.noDaysInMonth(date) else {
            log.error("Failed to determine number of days for date \(date)")
            return nil
        }

        let noRows = (startWeekday > 5) ? 6 : 5 // 6 rows if start weekday is at end of week

        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month], from: date)
        let todayComponents = (calendar as NSCalendar).components([.year, .month, .day], from: today)

        
        var calendarRows = [CalendarRow]()

        // first add the header row
        calendarRows.append(createHeader())

        var counter = 1
        for _ in 0..<noRows {
            let c = CalendarRow()
            for _ in 1...7 {
                let dayInMonth = counter - startWeekday
                if (dayInMonth <= 0) {
                    // day in previous month
                    let dayView = DayView() {
                        // ignore taps on days from previous month
                    }
                    c.days.append(dayView)
                    c.container.addSubview(dayView)
                }
                else if (dayInMonth > 0 && (dayInMonth <= noDaysInMonth)) {
                    // day in month
                    let currentDate = makeNSDate(components.year!, month: components.month!, day: dayInMonth)
                    let dayView = DayView() {
                        if let cb = self.dayPressedCallback {
                            cb(currentDate)
                        }
                    }
                    
                    if todayComponents.year == components.year && todayComponents.month == components.month && todayComponents.day == dayInMonth {
                        // highlight today
                        dayView.addLabel(NSString(format: "%d", dayInMonth) as String, bgColor: UIColor.white, fgColor: UIColor.red)
                    }
                    else {
                        dayView.addLabel(NSString(format: "%d", dayInMonth) as String)
                    }

                    // TODO below is very inefficient, fix this later
                    for i in 0..<chainsToShow.count {
                        let res = chainsToShow[i].dates.filter { return calendar.isDate($0, inSameDayAs: currentDate) }
                        if !res.isEmpty {
                            dayView.tick(UIColor.init(hexString: chainsToShow[i].color), position: i, total: chainsToShow.count)
                        }
                    }
                    c.days.append(dayView)
                    c.container.addSubview(dayView)
                }
                else {
                    // day in next month
                    let dayView = DayView() {
                        // ignore taps on days from next month
                    }
                    c.days.append(dayView)
                    c.container.addSubview(dayView)
                }
                counter += 1
            }
            calendarRows.append(c)
        }

        return calendarRows
    }

    fileprivate func createHeader() -> CalendarRow {
        let c = CalendarRow()

        let weekdaySymbols = dateUtils.getWeekdaySymbols()

        for i in weekdaySymbols {
            let dayView = DayView() {
                // ignore taps on header weekday symbols
            }
            dayView.addLabel(i, bgColor: UIColor.black, fgColor: UIColor.white)
            c.days.append(dayView)
            c.container.addSubview(dayView)
        }

        return c
    }

    fileprivate func makeNSDate(_ year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar.current

        var c = DateComponents()
        c.year = year
        c.month = month
        c.day = day

        return calendar.date(from: c)!
    }

}
