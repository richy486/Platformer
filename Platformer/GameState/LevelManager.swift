//
//  LevelManager.swift
//  Platformer
//
//  Created by Richard Adem on 21/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//
//  This class manages the game logic of a level

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
        
        if let player = player {
            camera.update(currentTime: currentTime, targetObject: player)
        }
        
        // Updated Actors vs Actors
        // handleP2ObjCollisions();
        // handleObj2ObjCollisions();
        var attachmentUUIDsToAttach: [(attach: UUID, to: UUID)] = []
        for a in actors {
            for b in actors {
                guard a.key != b.key else {
                    continue
                }
                
                let collisionResult = a.value.tryCollide(withObject: b.value)
                switch collisionResult {
                case .attach:
                    // a will attach to b
                    attachmentUUIDsToAttach.append((attach: a.key, to: b.key))
                default:
                    break
                }
                
            }
        }
        for attachmentUUIDs in attachmentUUIDsToAttach {
            guard var carrier = actors[attachmentUUIDs.to] as? ActorCarrier else {
                print("Attampting to attach \(attachmentUUIDs.attach) to non-attachable carrier: \(attachmentUUIDs.to)")
                continue
            }
            guard let attachedObject = actors.removeValue(forKey: attachmentUUIDs.attach) else {
                print("No attachment actor for UUID: \(attachmentUUIDs.attach)")
                return
            }
            carrier.actors[attachmentUUIDs.attach] = attachedObject
            
        }
        
        // Other Updates
        // game_values.gamemode->think();
        //  Update gametimer etc.
        // g_map->update();
        //  warps, animated tiles
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

            }
        }
    }

}
