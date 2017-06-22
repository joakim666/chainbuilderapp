//
//  ChainConfigurationViewModel.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-06-21.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

class ChainConfigurationViewModel {
    
    var configurationMode = false
    var chain: Chain?
    
    func configure(_ chain: Chain) {
        self.chain = chain
        self.configurationMode = true
    }
    
    func chainName() -> String {
        if let chain = self.chain {
            if let name = chain.name {
                return name
            }
        }
        log.warning("Could not get chain name")
        return ""
    }
}
