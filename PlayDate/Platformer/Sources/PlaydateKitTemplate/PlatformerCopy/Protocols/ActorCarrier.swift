//
//  ActorCarrier.swift
//  Platformer
//
//  Created by Richard Adem on 21/11/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

// import Foundation
//import CoreGraphics
//import UIKit

class ActorHolder<A: Actor> {
  let actor: A
  init(actor: A) {
    self.actor = actor
  }
}

func collide<A: Collision, B: Actor>(a: A, b: B) -> CollideResult {
  return a.tryCollide(withObject: b)
}


public protocol ActorCarrier: AnyObject {
  var actors: [UUID: Actor] { get set }

}

public extension ActorCarrier {
  func allActorsAndSubActors() -> [UUID: Actor] {
    var allActorsAndKeys: [UUID: Actor] = [:]
    
    for actor in actors {
      allActorsAndKeys[actor.key] = actor.value

      // Disabled in embedded.
      /*
      if let subActorCarrier = actor.value as? ActorCarrier {
        let subActorsAndKeys = subActorCarrier.allActorsAndSubActors()
        allActorsAndKeys.merge(subActorsAndKeys) { (a, _) -> Actor in
          return a
        }
      }
       */

    }
    return allActorsAndKeys
  }

//  func addActor<A: Actor>(_ actor: A) {
//    let uuid = UUID()
////    actors[uuid] = actor
////    actors.insert(actor, forKey: uuid)
//    actors.updateValue(actor, forKey: uuid)
//  }

  func addActor(_ actor: some Actor) {
    let uuid = UUID()
//    actors[uuid] = actor
    let actorHolder = ActorHolder(actor: actor)
    actors.updateValue(actor, forKey: uuid)
  }
}
