//
//  ChainConfigurationViewModel.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-06-21.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import UIKit

class ChainConfigurationViewModel {
    
    var configurationMode = false
    var chain: Chain?
    var callback: (() -> Void)?

    
    var name: String?
    var startDateEnabled: Bool?
    var startDate: Date?
    var color: UIColor?
    
    init() {
    }
    
    /**
     Configures the view model
     
     - Parameter chain:     The chain to configure
     - Parameter callback:  The callback to call when the configuration action is finished (i.e. to refresh the parent ui)
 
    */
    func configure(_ chain: Chain, callback: @escaping () -> Void) {
        self.chain = chain
        self.callback = callback
        self.configurationMode = true
        
        if let n = chain.name {
            self.name = n
        }

        self.startDateEnabled = chain.startDateEnabled
        self.startDate = chain.startDate
        
        self.color = UIColor(hexString: chain.color)
    }
    
    func save() {
        self.configurationMode = false
        
        guard let chain = self.chain else {
            log.error("No chain set")
            return
        }
        
        do {
            let realm = try RealmUtils.create()
            try realm.write {
                chain.name = self.name
                if let startDateEnabled = self.startDateEnabled {
                    chain.startDateEnabled = startDateEnabled
                }
                chain.startDate = self.startDate
                if let color = self.color {
                    chain.color = color.toHexString()
                }
            }
        }
        catch {
            log.error("Failed to modify chain: \(error.localizedDescription))")
        }
    }
}
