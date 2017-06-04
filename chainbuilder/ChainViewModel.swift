//
//  ChainViewModel.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-01-19.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import Foundation
import RealmSwift


class ChainViewModel {
    
    func createDefaultChainsIfNonePresent() {
        let realm: Realm
        do {
            realm = try RealmUtils.create()
        }
        catch {
            log.error("Failed to initialize db: \(error.localizedDescription)")
            return
        }
        
        do {
            try realm.write {
                let chains = realm.objects(Chain.self)
                
                if chains.isEmpty {
                    // chain 1
                    let chain1 = Chain()
                    chain1.id = UUID().uuidString
                    chain1.name = "Untitled 1"
                    chain1.sortOrder = 1
                    chain1.color = "dc322f"
                    realm.add(chain1)

                    // chain 2
                    let chain2 = Chain()
                    chain2.id = UUID().uuidString
                    chain2.name = "Untitled 2"
                    chain2.sortOrder = 2
                    chain2.color = "4bdc2e"
                    realm.add(chain2)

                    // chain 3
                    let chain3 = Chain()
                    chain3.id = UUID().uuidString
                    chain3.name = "Untitled 3"
                    chain3.sortOrder = 3
                    chain3.color = "2e5cdc"
                    realm.add(chain3)
                }
            }
        }
        catch {
            log.error("Failed to save object: \(error.localizedDescription))")
            return
        }
    }
    
    func addOrRemove(chainId: String, date: Date) {
        let realm: Realm
        do {
            realm = try RealmUtils.create()
        }
        catch {
            log.error("Failed to initialize db: \(error.localizedDescription)")
            return
        }
        
        guard let chain = realm.object(ofType: Chain.self, forPrimaryKey: chainId) else {
            log.warning("Didn't find any chain for primary key \(chainId)")
            return
        }

        
        let cd = ChainDate()
        cd.date = date

        
        do {
            try realm.write {
                var i = 0
                for cd in chain.days {
                    if cd.date == date {
                        log.info("Removing \(date) from index \(index)")
                        chain.days.remove(objectAtIndex: i)
                        return
                    }
                    i += 1
                }
                
                // not found, add it
                log.info("Adding \(date)")
                chain.days.append(cd)
            }
        }
        catch {
            log.error("Failed to modify chain: \(error.localizedDescription))")
            return
        }

    }

    func createChain(chainId: String) {
        let realm: Realm
        do {
            realm = try RealmUtils.create()
        }
        catch {
            log.error("Failed to initialize db: \(error.localizedDescription)")
            return
        }

        if let _ = realm.object(ofType: Chain.self, forPrimaryKey: chainId) {
            log.warning("There already exists a chain with id \(chainId)")
            return
        }

        let chain = Chain()
        chain.id = chainId
        
        // save in db
        do {
            try realm.write {
                realm.add(chain)
            }
        }
        catch {
            log.error("Failed to save object: \(error.localizedDescription))")
            return
        }
        
        
    }

    // TODO remove optional part of optional chainId
    func dates(chainId: String?) -> [Date] {
        let realm: Realm
        do {
            realm = try RealmUtils.create()
        }
        catch {
            log.error("Failed to initialize db: \(error.localizedDescription)")
            return []
        }

        // If a chainId was given use that chain, otherwise use the first chain (there should always be at least one chain!)
        // When the app starts a chain is created if none exists.
        
        let ch: Chain
        
        if let chainId = chainId {
            guard let chain = realm.object(ofType: Chain.self, forPrimaryKey: chainId) else {
                log.warning("Didn't find any chain for primary key \(chainId)")
                return []
            }
            ch = chain
            
        }
        else {
            guard let chain = realm.objects(Chain.self).first else {
                log.error("Didn't find any first chain!")
                return []
            }
            ch = chain
        }
        

        var dates = [Date]()
        
        for cd in ch.days {
            if let d = cd.date {
                dates.append(d)
            }
        }
        
        return dates
    }
    
    func chains() -> Results<Chain>? {
        let realm: Realm
        do {
            realm = try RealmUtils.create()
        }
        catch {
            log.error("Failed to initialize db: \(error.localizedDescription)")
            return nil
        }

        return realm.objects(Chain.self).sorted(byKeyPath: "sortOrder", ascending: true)
    }
    
    func updateName(chain: Chain, name: String) {
        do {
            let realm = try RealmUtils.create()
            try realm.write {
                chain.name = name
            }
        }
        catch {
            log.error("Failed to modify chain: \(error.localizedDescription))")
            return
        }
    }
}
