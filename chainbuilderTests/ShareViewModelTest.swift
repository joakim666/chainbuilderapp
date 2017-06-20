//
//  ShareViewModelTest.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-06-20.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import RealmSwift
import Nimble
import XCTest
@testable import chainbuilder_dev

class ShareViewModelTest: XCTestCase {
    
    func testNoChain() {
        let vm = ShareViewModel()
        vm.shareChain(nil)
        
        expect(vm.sharedFileURL()).to(beNil())
        expect(vm.completed()).toNot(throwError())
    }
    
    func testExport() {
        let vm = ShareViewModel()
        let chain = createTestChain()
        
        vm.shareChain(chain)
        
        let shareFileURL = vm.sharedFileURL()
        expect(shareFileURL).toNot(beNil())
        
        let csvData: String
        do {
            csvData = try String(contentsOf: shareFileURL!, encoding: .utf8)
        }
        catch {
            XCTFail("Failed to read content of exported CSV file")
            return
        }
        
        expect(csvData).toNot(beNil())
        expect(csvData).toNot(beEmpty())

        let expectedCsvString = "Marked dates\n1/1/17\n1/4/17\n1/5/17\n"
        
        expect(csvData).to(equal(expectedCsvString))
        
        expect(vm.completed()).toNot(throwError())
    }
    
    // --- Helper methods below
    
    func createTestChain() -> Chain {
        var config = Realm.Configuration()
        config.inMemoryIdentifier = "shareViewModelTest"
        
        let testRealm = try! Realm(configuration: config)
        
        let chainId = UUID().uuidString
        
        try! testRealm.write {
            // chain 1
            let chain1 = Chain()
            chain1.id = chainId
            chain1.name = "Tap to change 1"
            chain1.sortOrder = 1
            chain1.color = "dc322f"
            testRealm.add(chain1)
            
            let cd1 = ChainDate()
            cd1.date = DateUtilsTests.makeNSDate(2017, month: 1, day: 1)
            chain1.days.append(cd1)
            
            let cd2 = ChainDate()
            cd2.date = DateUtilsTests.makeNSDate(2017, month: 1, day: 4)
            chain1.days.append(cd2)
                
            let cd3 = ChainDate()
            cd3.date = DateUtilsTests.makeNSDate(2017, month: 1, day: 5)
            chain1.days.append(cd3)
        }
        
        guard let chain = testRealm.object(ofType: Chain.self, forPrimaryKey: chainId) else {
            XCTFail("Failed to find created chain")
            return Chain()
        }
        
        return chain
    }
}
