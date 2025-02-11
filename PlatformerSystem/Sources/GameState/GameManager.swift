//
//  GameManager.swift
//  Platformer
//
//  Created by Richard Adem on 21/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//
//  This class manages the level selection and other tasks like a possible title screen, world map etc.
//


public class GameManager {
  public var levelManager: LevelManager
  public var player: Player

  public init() {
    print("Create player")
    player = Player()

    print("Create level")
    let level = Level()

    print("Create Level Manager")
    levelManager = LevelManager(level: level, player: player)

    let actorsCount = allActors().count
    print("Level Manager loaded with \(actorsCount) actors (including sub actors)")
  }
  
  public func update(currentTime: TimeInterval, controls: Controls) {
    levelManager.update(currentTime: currentTime, controls: controls)
  }
  
  
  
  public func setLevel(_ level: Level) {
    levelManager.level = level
  }
  
  // Level elements
  
  public func allBlocks() -> [[Int]] {
    return levelManager.level.blocks
  }
  
  public func allActors() -> [UUID : Actor] {
    return levelManager.allActorsAndSubActors()
  }
  
  public func cameraPosition() -> Point {
//    print("cameraPosition()")

    let camera = levelManager.camera
//    print("camera: \(camera)")
    let position = camera.position
//    print("position: \(position)")
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
