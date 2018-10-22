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
    var levelManager: LevelManager?
    
    init() {
        let level = Level()
        
        
        let blocks = level.blocks.map({ rowInts -> [TileTypeFlag] in
            rowInts.map({ tileInt -> TileTypeFlag in
                TileTypeFlag(rawValue: tileInt)
            })
        })
        
        levelManager = LevelManager(blocks: blocks)
        
    }
    
    func update(currentTime: TimeInterval, controls: Controls) {
        levelManager?.update(currentTime: currentTime, controls: controls)
    }
}
