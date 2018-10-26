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
    var actors: [UUID: CollisionObject] = [:]
    let camera = Camera()
    
    var level: Level
    
    init(level: Level, player: Player) {
        self.level = level
        self.actors[UUID()] = player
        restart()
    }
    
    func update(currentTime: TimeInterval, controls: Controls) {
        
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
    }
    
    func restart() {
        for (y, xBlocks) in level.blocks.enumerated() {
            for (x, blockVal) in xBlocks.enumerated() {
                
                let tileType = TileTypeFlag(rawValue: blockVal)
                if tileType.contains(.player_start) {
                    
                    var player: Player?
                    for actor in actors.values {
                        if let playerActor = actor as? Player {
                            player = playerActor
                        }
                    }
                    
                    if let player = player {
                        player.f = CGPoint(x: x*TILESIZE + (TILESIZE/2) - PW/2,
                                           y: y*TILESIZE + (TILESIZE - PH) - 1)

                        let groundPos = Int((player.f.y + CGFloat(PH)) / CGFloat(TILESIZE))
                        let cameraY = CGFloat((groundPos + AppState.shared.BLOCKSOFFCENTER) * TILESIZE)
                        
                        camera.position = CGPoint(x: player.f.x,
                                                  y: cameraY)
                    }


                }

            }
        }
    }

}
