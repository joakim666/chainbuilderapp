//
//  SlotsViewModel.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-04-19.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import RealmSwift

/**
 * The view model for the slots that it is possible to pan up and down between.
 *
 * Adds the overview and then acts as a proxy for the Realm based chains
 */
class SlotsViewModel {
    private let chains: Results<Chain>
    
    var activeSlot = 0
    
    init(chains: Results<Chain>) {
        self.chains = chains
    }
    
    func count() -> Int {
        return 1 + self.chains.count // add one for the overview
    }
    
    func isValidSlot(index: Int) -> Bool {
        return index >= 0 && index < count()
    }
    
    func newViewControllerForSlotAt(index: Int, currentDateViewModel: CurrentDateViewModel) -> CalendarViewController? {
        guard isValidSlot(index: index) else {
            log.debug("Index \(index) is out of range")
            return nil
        }
        
        let vc: CalendarViewController
        
        if index == 0 {
            vc = OverviewController(currentDateViewModel: currentDateViewModel)
        }
        else {
            // -1 to accomodate for the overview view being at index 0 in the slots view
            vc = ChainViewController(chain: self.chains[index-1], currentDateViewModel: currentDateViewModel)
        }
        
        return vc
    }
    
}
