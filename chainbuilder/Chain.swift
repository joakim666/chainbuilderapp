//
//  Chain.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-01-19.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import Foundation
import RealmSwift

class ChainDate : Object {
    dynamic var date: Date?
}

class Chain : Object {
    dynamic var id: String?                     // unique uuid
    dynamic var name: String?                   // name of chain displayed in the app
    dynamic var sortOrder = 99                  // determines the order in which the chains are shown
    dynamic var color = "000000"                // the color of the chain as a rgb hex string
    dynamic var startDateEnabled: Bool = false  // whether a start date is set for the chain or not
    dynamic var startDate: Date?                // the start date if it's set
    
    let days = List<ChainDate>()
    
    // use the id property as the primary key for this object
    override static func primaryKey() -> String? {
        return "id"
    }
}

class ChainItem {
    let chainId: Int
    let date: Date
    
    init (chainId: Int, date: Date) {
        self.chainId = chainId
        self.date = date
    }
}
