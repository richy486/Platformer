//
//  LevelManager.swift
//  Platformer
//
//  Created by Richard Adem on 21/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//
//  This class manages the game logic of a level

import Foundation

class LevelManager {
    var actors: [UUID: CollisionObject & Collision] = [:]
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
        for a in actors {
            for b in actors {
                guard a.key != b.key else {
                    continue
                }
                
                a.value.tryCollide(withObject: b.value)
                
                // a.collide(b)
                
            }
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
                    
                    
                    player.f = CGPoint(x: x*TILESIZE + (TILESIZE/2) - PW/2,
                                       y: y*TILESIZE + (TILESIZE - PH) - 1)

                    let groundPos = Int((player.f.y + CGFloat(PH)) / CGFloat(TILESIZE))
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
