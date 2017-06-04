//
//  SlotsViewModelTest.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-04-20.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import RealmSwift
import Nimble
import XCTest
@testable import chainbuilder_dev

class SlotsViewModelTest: XCTestCase {

    func testThreeSlots() {
        var config = Realm.Configuration()
        config.inMemoryIdentifier = "slotsViewModelTest"

        let testRealm = try! Realm(configuration: config)

        try! testRealm.write {
            // chain 1
            let chain1 = Chain()
            chain1.id = UUID().uuidString
            chain1.name = "Tap to change 1"
            chain1.sortOrder = 1
            chain1.color = "dc322f"
            testRealm.add(chain1)
            
            // chain 2
            let chain2 = Chain()
            chain2.id = UUID().uuidString
            chain2.name = "Tap to change 2"
            chain2.sortOrder = 2
            chain2.color = "d33682"
            testRealm.add(chain2)
            
            // chain 3
            let chain3 = Chain()
            chain3.id = UUID().uuidString
            chain3.name = "Tap to change 3"
            chain3.sortOrder = 3
            chain3.color = "6c71c4"
            testRealm.add(chain3)
        }
        
        let chains = testRealm.objects(Chain.self).sorted(byKeyPath: "sortOrder", ascending: true)

        let slotsViewModel = SlotsViewModel(chains: chains)

        expect(slotsViewModel.count()).to(equal(4))
        expect(slotsViewModel.isValidSlot(index: -1)).to(equal(false))
        expect(slotsViewModel.isValidSlot(index: 0)).to(equal(true))
        expect(slotsViewModel.isValidSlot(index: 1)).to(equal(true))
        expect(slotsViewModel.isValidSlot(index: 2)).to(equal(true))
        expect(slotsViewModel.isValidSlot(index: 3)).to(equal(true))
        expect(slotsViewModel.isValidSlot(index: 4)).to(equal(false))
        
        let currentDateViewModel = CurrentDateViewModel()
        
        let i0 = slotsViewModel.newViewControllerForSlotAt(index: 0, currentDateViewModel: currentDateViewModel)
        expect(i0).to(beAKindOf(OverviewController.self))
        
        let i1 = slotsViewModel.newViewControllerForSlotAt(index: 1, currentDateViewModel: currentDateViewModel)
        expect(i1).to(beAKindOf(ChainViewController.self))
        
        let i2 = slotsViewModel.newViewControllerForSlotAt(index: 2, currentDateViewModel: currentDateViewModel)
        expect(i2).to(beAKindOf(ChainViewController.self))

        let i3 = slotsViewModel.newViewControllerForSlotAt(index: 3, currentDateViewModel: currentDateViewModel)
        expect(i3).to(beAKindOf(ChainViewController.self))
    }

}
