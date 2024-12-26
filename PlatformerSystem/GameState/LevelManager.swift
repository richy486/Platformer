//
//  LevelManager.swift
//  Platformer
//
//  Created by Richard Adem on 21/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//
//  This class manages the game logic of a level

import CoreGraphics
//import UIKit
import Foundation

class LevelManager: ActorCarrier {
  var actors: [UUID: Actor] = [:]
  let camera = Camera()
  weak var player: Player!
  
  var level: Level
  
  init(level: Level, player: Player) {
    self.level = level
    self.player = player
    restart()
  }
  
  func update(currentTime: TimeInterval, controls: Controls) {
    
    // Update Player vs Player?
    // handleP2PCollisions();
    
    // Update Actors vs Level
    // list_players[i]->move();
    var player: Player?
    for actor in actors.values {
      
      if let playerActor = actor as? Player {
        level = playerActor.update(currentTime: currentTime, controlCommands: controls.player, level: level)
        player = playerActor
      } else {
        level = actor.update(currentTime: currentTime, level: level)
      }
    }
    
    // Camera
    
    if let player = player {
      camera.update(currentTime: currentTime, targetObject: player)
    }
    
    // Updated Actors vs Actors
    // handleP2ObjCollisions();
    // handleObj2ObjCollisions();
    
    //        var attachmentUUIDsToAttach: [(attach: UUID, to: UUID)] = []
    var attachmentActorsToAttach: [(attach: (uuid: UUID, actor: Actor), from: ActorCarrier, to: ActorCarrier)] = []
    for a in actors {
      for b in actors {
        guard a.key != b.key else {
          continue
        }
        
        let collisionResult = a.value.tryCollide(withObject: b.value)
        switch collisionResult {
        case .attach:
          // a will attach to b
          //                    attachmentUUIDsToAttach.append((attach: a.key, to: b.key))
          
          if let newCarrier = b.value as? ActorCarrier {
            let uuidActor = (uuid: a.key, actor: a.value)
            attachmentActorsToAttach.append((attach: uuidActor, from: self, to: newCarrier))
          }
        default:
          break
        }
        
      }
    }
    
    // Drop all carried objects if not in turbo
    if let player = player, controls.player.turbo == false {
      for a in player.actors {
        let uuidActor = (uuid: a.key, actor: a.value)
        attachmentActorsToAttach.append((attach: uuidActor, from: player, to: self))
      }
    }
    
    for attachments in attachmentActorsToAttach {
      let uuid = attachments.attach.uuid
      var from = attachments.from
      var to = attachments.to
      
      guard let attachable = from.actors.removeValue(forKey: uuid) else {
        print("No attachment actor for UUID: \(uuid)")
        continue
      }
      
      to.actors[uuid] = attachable
      
      if let dropableAttachable = attachable as? Droppable,
         let dropper = from as? Actor,
         to is LevelManager {
        
        dropableAttachable.drop(by: dropper)
      }
    }
  }
  
  func restart() {
    actors.removeAll()
    
    for (y, xBlocks) in level.blocks.enumerated() {
      for (x, blockVal) in xBlocks.enumerated() {
        
        let tileType = TileTypeFlag(rawValue: blockVal)
        if tileType.contains(.player_start) {
          
          if actors.contains(where: { $0.value is Player }) == false {
            actors[UUID()] = player
          }
          
          
          player.f = CGPoint(x: x*TILESIZE + (TILESIZE/2) - player.size.width/2,
                             y: y*TILESIZE + (TILESIZE - player.size.height) - 1)
          
          let groundPos = Int((player.f.y + CGFloat(player.size.height)) / CGFloat(TILESIZE))
          let cameraY = CGFloat((groundPos + AppState.shared.BLOCKSOFFCENTER) * TILESIZE)
          
          camera.position = CGPoint(x: player.f.x,
                                    y: cameraY)
          
        }
        
        if tileType.contains(.pickup) {
          // Create a Pickup actor
          
          let pickup = Pickup()
          actors[UUID()] = pickup
          
          pickup.f = CGPoint(x: x*TILESIZE,
                             y: y*TILESIZE)
        }
        if tileType.contains(.piggy) {
          // Create a Pickup actor
          
          let piggy = Piggy()
          actors[UUID()] = piggy
          
          piggy.f = CGPoint(x: x*TILESIZE,
                            y: y*TILESIZE)
        }
        if tileType.contains(.jsItem) {
          // Create a Pickup actor
          
          let jsItem = JSItem()
          actors[UUID()] = jsItem
          
          jsItem.f = CGPoint(x: x*TILESIZE,
                             y: y*TILESIZE)
        }
        if tileType.contains(.pickAxe) {
          // Create a Pickup actor

          // TODO: Pick Axe
          let pickAxe = PickAxe()
          actors[UUID()] = pickAxe

          pickAxe.f = CGPoint(x: x*TILESIZE,
                            y: y*TILESIZE)
        }

      }
    }
  }
  
}
