//
//  CurrentChainViewModel.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-01-28.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import Foundation
import RealmSwift

class CurrentChainViewModel {
    
    func selectedChain() -> String? {
        let realm: Realm
        do {
            realm = try RealmUtils.create()
        }
        catch {
            log.error("Failed to initialize db: \(error.localizedDescription)")
            return nil
        }
        
        var res: String?
        
        if let state = realm.objects(State.self).first {
            if let selectedChain = state.selectedChain {
                res = selectedChain
            }
        }

        return res
    }
}
