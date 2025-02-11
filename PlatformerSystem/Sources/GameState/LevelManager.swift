//
//  LevelManager.swift
//  Platformer
//
//  Created by Richard Adem on 21/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//
//  This class manages the game logic of a level

public class LevelManager: ActorCarrier {
  public var actors: [UUID: Actor] = [:]
  let camera = Camera()
  var player: Player!
  
  public var level: Level
  
  init(level: Level, player: Player) {
    print("Set level")
    self.level = level
    print("Set player")
    self.player = player
    restart()
  }
  
  func update(currentTime: TimeInterval, controls: Controls) {
    
    // Update Actors vs Level
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
    var attachmentActorsToAttach: [(attach: (uuid: UUID, actor: Actor), from: ActorCarrier, to: ActorCarrier)] = []
    for a in actors {
      for b in actors {
        guard a.key != b.key else {
          continue
        }

        let collisionResult = a.value.tryCollide(withObject: b.value)
        switch collisionResult {
        case .attach:
          let uuidActor = (uuid: a.key, actor: a.value)
          attachmentActorsToAttach.append((attach: uuidActor, from: self, to: b.value))
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
      let from = attachments.from
      let to = attachments.to
      guard let attachable = from.actors.removeValue(forKey: uuid) else {
        print("No attachment actor for UUID: \(uuid)")
        continue
      }

      to.actors[uuid] = attachable
      
      if /*let dropableAttachable = attachable as? Droppable,*/
         let dropper = from as? Actor,
         to is LevelManager {
        
        //dropableAttachable.drop(by: dropper)
        attachable.drop(by: dropper)
      }
    }
  }
  
  public func restart() {
    print("Restart")
    actors.removeAll()
    
    for (y, xBlocks) in level.blocks.enumerated() {
      for (x, blockVal) in xBlocks.enumerated() {
        let tileType = TileTypeFlag(rawValue: blockVal)
        if tileType.contains(.player_start) {

          if actors.contains(where: { $0.value is Player }) == false {
            actors[UUID()] = player
          }
          
          
          player.f = Point(x: x*TILESIZE + (TILESIZE/2) - player.size.width/2,
                             y: y*TILESIZE + (TILESIZE - player.size.height) - 1)
          
          let groundPos = Int((player.f.y + Double(player.size.height)) / Double(TILESIZE))
          let cameraY = Double((groundPos + AppState.shared.BLOCKSOFFCENTER) * TILESIZE)
          
          camera.position = Point(x: player.f.x,
                                    y: cameraY)
          
        }
        
        if tileType.contains(.pickup) {
          // Create a Pickup actor
          
          let pickup = Pickup()
          actors[UUID()] = pickup

          pickup.f = Point(x: x*TILESIZE,
                             y: y*TILESIZE)
        }
        if tileType.contains(.piggy) {
          // Create a Pickup actor
          
          let piggy = Piggy()
          actors[UUID()] = piggy
          
          piggy.f = Point(x: x*TILESIZE,
                            y: y*TILESIZE)
        }
        // TODO: Allow external items
//        if tileType.contains(.jsItem) {
//          // Create a Pickup actor
//          
//          let jsItem = JSItem()
//          actors[UUID()] = jsItem
//          
//          jsItem.f = Point(x: x*TILESIZE,
//                             y: y*TILESIZE)
//        }
        if tileType.contains(.pickAxe) {
          // Create a Pickup actor

          let pickAxe = PickAxe()
          actors[UUID()] = pickAxe

          pickAxe.f = Point(x: x*TILESIZE,
                            y: y*TILESIZE)
        }
      }
    }
  }
  
}
