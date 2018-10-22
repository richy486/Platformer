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
    var blocks: [[TileTypeFlag]] = []
    var actors: [CollisionObject] = []
    let camera = Camera()
    
    var level: Level = Level()
    
    init(blocks: [[TileTypeFlag]]) {
        self.blocks = blocks
        
    }
    
    func update(currentTime: TimeInterval, controls: Controls) {
        
        var player: Player?
        for actor in actors {
            
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

}
