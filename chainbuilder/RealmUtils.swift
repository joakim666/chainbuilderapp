//
//  RealmUtils.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-01-28.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import Foundation
import RealmSwift

class RealmUtils {
    
    public static func create() throws -> Realm {
        var config = Realm.Configuration()
        
        if GlobalSettings.demoMode {
            config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("demo.realm")
        }

        config.schemaVersion = 2
        
        config.migrationBlock = { migration, oldSchemaVersion in
            
            migration.enumerateObjects(ofType: Chain.className()) { oldObject, newObject in
                if oldSchemaVersion < 1 {
                    let sortOrder = oldObject!["sortOrder"] as! Int
                    let chainName = oldObject!["name"] as! String
                    
                    if sortOrder == 1 {
                        if chainName == "Tap to change 1" {
                            newObject!["name"] = "Untitled 1"
                        }
                        // don't change the color, keep the red color
                    }
                    else if sortOrder == 2 {
                        if chainName == "Tap to change 2" {
                            newObject!["name"] = "Untitled 2"
                        }
                        newObject!["color"] = "4bdc2e"  // change to green color
                    }
                    else if sortOrder == 3 {
                        if chainName == "Tap to change 3" {
                            newObject!["name"] = "Untitled 3"
                        }
                        newObject!["color"] = "2e5cdc" // change to blue color
                    }
                }
                if oldSchemaVersion >= 1 && oldSchemaVersion < 2 {
                    newObject!["startDateEnabled"] = false
                }
            }
        }
        
        Realm.Configuration.defaultConfiguration = config

        let realm = try Realm()
        
        if let path = realm.configuration.fileURL {
            log.debug("Using path\(path)")
        }
        
        realm.refresh() // refresh to make sure the data is up to date
        
        return realm
    }
}
