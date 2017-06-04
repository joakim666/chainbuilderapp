//
//  CurrentDateViewModel.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-01-19.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import Foundation

/**
 * Model for which date (i.e. month) that is shown.
 */
class CurrentDateViewModel {

    let dateUtils = DateUtils()

    fileprivate(set) var selectedDate = Date()
    fileprivate(set) var selectedMonthName : String

    init() {
        selectedMonthName = dateUtils.monthAndYear(selectedDate)
    }
    
    func select(date: Date) {
        selectedDate = date
        selectedMonthName = dateUtils.monthAndYear(selectedDate)
    }
    
    func adjustMonth(direction: Int) {
        log.debug("Adjusting month with \(direction)")
        let calendar = NSCalendar.current
        var components = DateComponents()
        components.month = direction
        
        guard let date = calendar.date(byAdding: components, to: selectedDate) else {
            log.error("A date could not be created given the input")
            return
        }
        
        selectedDate = date
        selectedMonthName = dateUtils.monthAndYear(date)
    }
    
    // Returns a new instance of this class with the month adjusted by the given direction
    func adjustedViewModel(directon: Int) -> CurrentDateViewModel {
        let vm = CurrentDateViewModel()
        vm.select(date: selectedDate)
        vm.adjustMonth(direction: directon)

        return vm
    }
    
}
