//
//  GameManager.swift
//  Platformer
//
//  Created by Richard Adem on 21/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//
//  This class manages the level selection and other tasks like a possible title screen, world map etc.
//

import Foundation

class GameManager {
    var levelManager: LevelManager
    var player: Player
    
    init() {
        
        player = Player()
        let level = Level()
        levelManager = LevelManager(level: level, player: player)
    }
    
    func update(currentTime: TimeInterval, controls: Controls) {
        levelManager.update(currentTime: currentTime, controls: controls)
    }
    
    func loadLevel() {
        let level: Level
        if let loadedLevel = Level(withFilename: "Level 1") {
            level = loadedLevel
        } else {
            level = Level()
        }
        
        levelManager = LevelManager(level: level, player: player)
        
        player.restart()
    }
}
