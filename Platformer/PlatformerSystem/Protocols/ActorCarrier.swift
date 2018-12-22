//
//  ActorCarrier.swift
//  Platformer
//
//  Created by Richard Adem on 21/11/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

public protocol ActorCarrier {
    var actors: [UUID: Actor] { get set }
}

public extension ActorCarrier {
    public func allActorsAndSubActors() -> [UUID: Actor] {
        var allActorsAndKeys: [UUID: Actor] = [:]
        
        for actor in actors {
            allActorsAndKeys[actor.key] = actor.value
            
            if let subActorCarrier = actor.value as? ActorCarrier {
                let subActorsAndKeys = subActorCarrier.allActorsAndSubActors()
                allActorsAndKeys.merge(subActorsAndKeys) { (a, _) -> Actor in
                    return a
                }
            }
            
        }
        return allActorsAndKeys
    }
}
