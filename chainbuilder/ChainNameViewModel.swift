//
//  ChainNameViewModel.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-03-09.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

class ChainNameViewModel {
    var editMode = false
    var name: String?
    
    func reset(_ name: String?) {
        self.name = name
        editMode = true
    }
    
    func save(_ name: String?) {
        editMode = false
    }
    
    func cancel() {
        editMode = false
    }
}
