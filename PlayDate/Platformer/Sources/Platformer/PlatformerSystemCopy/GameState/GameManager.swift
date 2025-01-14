//
//  GameManager.swift
//  Platformer
//
//  Created by Richard Adem on 21/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//
//  This class manages the level selection and other tasks like a possible title screen, world map etc.
//

//import CoreGraphics
//import UIKit
// import Foundation

//#if PLAYDATE
//import PlaydateKit
////#endif
////
////#if ITSANAPPLEPLATFORM
////
////#else
////import Foundation
//#endif


public class GameManager {
  var levelManager: LevelManager
  public var player: Player
  public let observer = Observer()

  public init() {

#if PLAYDATE
    print("!!! play date build")
#else
    print("!!! Another type of build")
#endif

    player = Player()
    let level = Level(observer: observer)
    levelManager = LevelManager(level: level, player: player)


  }
  
  public func update(currentTime: TimeInterval, controls: Controls) {
    levelManager.update(currentTime: currentTime, controls: controls)
  }
  
  // Level I/O
  
  public func loadLevel() {
    // Disabled in embedded.
//    let level: Level
//    if let loadedLevel = Level(withFilename: "Level 1") {
//      level = loadedLevel
//    } else {
//      level = Level()
//    }
//    
//    levelManager = LevelManager(level: level, player: player)
//    
//    player.restart()
  }
  
  public func setLevel(_ level: Level) {
    levelManager.level = level
  }
  
  public func saveLevel() {
    // Disabled in embedded.
//      levelManager.level.save()
  }
  
  // Level elements
  
  public func allBlocks() -> [[Int]] {
    return levelManager.level.blocks
  }
  
  public func allActors() -> [UUID : Actor] {
    return levelManager.allActorsAndSubActors()
  }
  
  public func cameraPosition() -> Point {
    print("cameraPosition()")

    let camera = levelManager.camera
    print("camera: \(camera)")
    let position = camera.position
    print("position: \(position)")
    return position
  }
  
  public func posToTile(_ position: Point) -> Int {
    return levelManager.level.posToTile(position)
  }
  
  public func posToTilePos(_ position: Point) -> (x: Int, y: Int) {
    return levelManager.level.posToTilePos(position)
  }
  
  public func setMap(x: Int, y: Int, tileType: TileTypeFlag) {
    levelManager.level.setMap(x: x, y: y, tileType: tileType)
  }
}
