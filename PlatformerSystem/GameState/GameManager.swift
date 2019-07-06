//
//  GameManager.swift
//  Platformer
//
//  Created by Richard Adem on 21/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//
//  This class manages the level selection and other tasks like a possible title screen, world map etc.
//

import CoreGraphics
import UIKit

public class GameManager {
  var levelManager: LevelManager
  public var player: Player
  
  public init() {
    
    player = Player()
    let level = Level()
    levelManager = LevelManager(level: level, player: player)
  }
  
  public func update(currentTime: TimeInterval, controls: Controls) {
    levelManager.update(currentTime: currentTime, controls: controls)
  }
  
  // Level I/O
  
  public func loadLevel() {
    let level: Level
    if let loadedLevel = Level(withFilename: "Level 1") {
      level = loadedLevel
    } else {
      level = Level()
    }
    
    levelManager = LevelManager(level: level, player: player)
    
    player.restart()
  }
  
  public func setLevel(_ level: Level) {
    levelManager.level = level
  }
  
  public func saveLevel() {
      levelManager.level.save()
  }
  
  // Level elements
  
  public func allBlocks() -> [[Int]] {
    return levelManager.level.blocks
  }
  
  public func allActors() -> [UUID : Actor] {
    return levelManager.allActorsAndSubActors()
  }
  
  public func cameraPosition() -> CGPoint {
    return levelManager.camera.position
  }
  
  public func posToTile(_ position: CGPoint) -> Int {
    return levelManager.level.posToTile(position)
  }
  
  public func posToTilePos(_ position: CGPoint) -> (x: Int, y: Int) {
    return levelManager.level.posToTilePos(position)
  }
  
  public func setMap(x: Int, y: Int, tileType: TileTypeFlag) {
    levelManager.level.setMap(x: x, y: y, tileType: tileType)
  }
}
