//
//  ActorCarrier.swift
//  Platformer
//
//  Created by Richard Adem on 21/11/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

public protocol ActorCarrier: AnyObject {
  var actors: [UUID: Actor] { get set }

}

public extension ActorCarrier {
  func allActorsAndSubActors() -> [UUID: Actor] {
    var allActorsAndKeys: [UUID: Actor] = [:]

    for actor in actors {
      allActorsAndKeys[actor.key] = actor.value

      let subActorsAndKeys = actor.value.allActorsAndSubActors()
      for (key, value) in subActorsAndKeys {
        allActorsAndKeys[key] = value
      }
    }
    return allActorsAndKeys
  }
}
