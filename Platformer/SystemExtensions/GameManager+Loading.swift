//
//  GameManager+Loading.swift
//  Platformer
//
//  Created by Richard Adem on 09/02/2025.
//  Copyright © 2025 Richard Adem. All rights reserved.
//

import PlatformerSystem

extension GameManager {
  // Level I/O

  public func loadLevel() {
    let level: Level
    if let loadedLevel = Level(withFilename: "Level 1") {
      level = loadedLevel
    } else {
      level = Level()
    }
    levelManager.level = level

    player.restart()
    levelManager.restart()
  }



  public func saveLevel() {
    levelManager.level.save()
  }
}
