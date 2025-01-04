//
//  Map.swift
//  Platformer
//
//  Created by Richard Adem on 21/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

//import CoreGraphics
//import UIKit
// import Foundation


public struct Level {
  public var name: String
  public var blocks: [[Int]]

  init() {
    name = "Level 1"
    blocks = [
      [S,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [S,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [0,0,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [0,0,S,0,0,0,S,S,S,0,S,0,S,0,S,S,S,S,0,S,0,S,0,S,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [0,0,S,S,0,0,0,0,0,S,S,S,S,0,S,0,0,0,S,0,S,T,T,S,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [0,0,0,S,S,S,0,S,0,0,0,0,0,S,0,0,0,0,0,0,0,0,0,0,T,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [0,0,0,0,0,0,S,0,0,S,S,S,S,0,0,0,0,0,0,T,T,0,T,0,T,0,T,0,T,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,T,S],
      [0,0,0,0,0,0,0,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
      [0,0,0,0,S,S,S,S,0,0,0,0,0,0,0,0,0,0,0,T,T,0,0,0,0,0,0,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S,S],
      [0,0,S,0,0,0,0,0,0,0,0,0,0,0,S,S,S,0,T,T,T,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [S,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S]
    ]
  }
}
/*

extension Level {

  init?(withFilename filename: String) {

    let jsonString: String
    let fileURL = URL(fileURLWithPath: "\(filename).json")
    print("loading from: \(fileURL)")
    do {
      jsonString = try String(contentsOf: fileURL, encoding: .utf8)
    } catch {
      print("Error loading: \(error)")
      return nil
    }

    guard let jsonData = jsonString.data(using: .utf8) else {
      print("Error string to data")
      return nil
    }

    let jsonDecoder = JSONDecoder()
    let level: Level
    do {
      level = try jsonDecoder.decode(Level.self, from: jsonData)
    } catch {
      print("Error decoding: \(error)")
      return nil
    }

    self = level
    print("Loaded!")
  }
}
extension Level: Codable {

  public func save() {
    
    var mutableSelf = self
    
    // Reset any run time changes
    for (y, xBlocks) in mutableSelf.blocks.enumerated() {
      for (x, blockVal) in xBlocks.enumerated() {
        
        let tileType = TileTypeFlag(rawValue: blockVal)
        
        if tileType.intersection(.used) == .used {
          
          // Remove used
          var updatedTile = tileType.symmetricDifference(.used)
          
          // Re add solid if breakable
          if tileType.contains(.breakable) {
            updatedTile = updatedTile.union(.solid)
          }
          
          mutableSelf.blocks[y][x] = updatedTile.rawValue
        }
      }
    }
    
    let jsonEncoder = JSONEncoder()
    let jsonData: Data
    do {
      jsonData = try jsonEncoder.encode(mutableSelf)
    } catch {
      print("Error encoding: \(error)")
      return
    }
    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
      print("Error json stat to string")
      return
    }
    
    let fileURL = URL(fileURLWithPath: "\(mutableSelf.name).json")
    do {
      try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
    } catch {
      print("Error writing: \(error)")
      return
    }
    print("Saved! \(fileURL.absoluteString)")
  }

}
 */

// Tile operations
extension Level {
  func tile(point: IntPoint) -> TileTypeFlag {
    let mapValue = map(point: point)
    let tileType = TileTypeFlag(rawValue: mapValue)
    return tileType
  }
  func map(point: IntPoint) -> Int {
    return map(x: point.x, y: point.y)
  }
  func map(x: Int, y: Int) -> Int {
    
    guard y >= 0 && y < blocks.count else {
      return -1
    }
    let xBlocks = blocks[y]
    guard x >= 0 && x < xBlocks.count else {
      return -1
    }
    
    return xBlocks[x]
  }
  
  func isGap(point: IntPoint) -> Bool {
    
    let pointSolid = tile(point: point).contains(.solid)
    let leftSolid = tile(point: IntPoint(x: point.x-1, y: point.y) ).contains(.solid)
    let rightSolid = tile(point: IntPoint(x: point.x+1, y: point.y) ).contains(.solid)
    let topLeftSolid = tile(point: IntPoint(x: point.x-1, y: point.y-1) ).contains(.solid)
    let topSolid = tile(point: IntPoint(x: point.x, y: point.y-1) ).contains(.solid)
    let topRightSolid = tile(point: IntPoint(x: point.x+1, y: point.y-1) ).contains(.solid)
    
    let isGap = leftSolid && !pointSolid && rightSolid && !topLeftSolid && !topSolid && !topRightSolid
    
    return isGap
  }
  
  func slopeDirection(forVelocity velocity: Point, andTile tile: TileTypeFlag) -> Direction {
    var direction: Direction = .stationary
    
    if tile.intersection(.slope_right).rawValue != 0 {
      if velocity.x > 0 {
        direction = .downRight
      } else if velocity.x < 0 {
        direction = .upLeft
      }
      
    } else if tile.contains(.slope_left) {
      if velocity.x > 0 {
        direction = .upRight
      } else if velocity.x < 0 {
        direction = .downLeft
      }
    }
    
    return direction
  }
  
  public mutating func setMap(x: Int, y: Int, tileType: TileTypeFlag) {
    
    guard y >= 0 && y < blocks.count else {
      return
    }
    let xBlocks = blocks[y]
    guard x >= 0 && x < xBlocks.count else {
      return
    }
    
    blocks[y][x] = tileType.rawValue

    // Disabled in embedded.
    /*
    NotificationCenter.default.post(name: Constants.kNotificationMapChange,
                                    object: self,
                                    userInfo: [
                                      Constants.kMapChangePoint: IntPoint(x: x, y: y),
                                      Constants.kMapChangeTileType: tileType
      ])
     */
  }
  
  public func posToTilePos(_ position: Point) -> (x: Int, y: Int) {
    let x = Int(position.x + 0.5) / TILESIZE
    let y = (Int(position.y + 0.5) / TILESIZE) //+ 1
    
    return (x, y)
  }
  
  public func posToTile(_ position: Point) -> Int {
    let tilePos = posToTilePos(position)
    
    return map(x: tilePos.x, y: tilePos.y)
  }
  
  mutating func collide(atPoint point: IntPoint, tileType: TileTypeFlag, direction: Direction, noTrigger: Bool = false) -> Bool {
    let tile = map(point: point)
    let mapTileType = TileTypeFlag(rawValue: tile)
    
    let usedBreakable = mapTileType.intersection(.used) == .used && mapTileType.intersection(.breakable) == .breakable
    let collisionTile = mapTileType.intersection(tileType).rawValue != 0
    
    let collide = collisionTile && !usedBreakable
    
    if collide && direction == .up {
      print("stop")
    }
    
    if !noTrigger && mapTileType.intersection(.used) != .used {
      if collide && mapTileType.contains(.breakable) && direction == .up {
        let updatedTile = mapTileType.symmetricDifference(.solid).union(.used)
        setMap(x: point.x, y: point.y, tileType: updatedTile)
      }
      
      if collide && mapTileType.contains(.powerup) && direction == .up {
        setMap(x: point.x, y: point.y, tileType: mapTileType.union(.used))
      }
      
    }
    
    return collide
  }
  
  func slopesBelow(position: Point, size: IntSize, level: Level) -> (left: TileTypeFlag?, right: TileTypeFlag?) {
    
    // TODO: this is also defined in CollisionObject
    let heightSlope = size.height - (size.width/2) - 1
    
    var y = (Int(position.y) + heightSlope) / TILESIZE
    let leftCheck = Int(position.x) / TILESIZE
    let centerCheck = (Int(position.x) + size.width/2) / TILESIZE
    let rightCheck = (Int(position.x) + size.width) / TILESIZE
    
    var foundSlopeLeft: TileTypeFlag? = nil
    var foundSlopeRight: TileTypeFlag? = nil
    
    var i = 0; // Check current tile and the next one
    while y < blocks.count && i < 2 {
      
      guard foundSlopeLeft == nil || foundSlopeRight == nil else {
        break
      }
      
      let leftTile = level.tile(point: IntPoint(x: leftCheck, y: y ))
      let centerTile = level.tile(point: IntPoint(x: centerCheck, y: y ))
      let rightTile = level.tile(point: IntPoint(x: rightCheck, y: y ))
      
      // Left side only cares about slopes that are facing right
      if foundSlopeLeft == nil && leftTile.intersection(.slope_right).rawValue != 0 {
        foundSlopeLeft = leftTile
      }
      if foundSlopeRight == nil && leftTile.intersection(.slope_left).rawValue != 0 {
        foundSlopeRight = leftTile
      }
      if centerTile != leftTile && foundSlopeLeft == nil && centerTile.intersection(.slope_right).rawValue != 0 {
        foundSlopeLeft = centerTile
      }
      if centerTile != rightTile && foundSlopeRight == nil && centerTile.intersection(.slope_left).rawValue != 0 {
        foundSlopeRight = centerTile
      }
      if foundSlopeRight == nil && rightTile.intersection(.slope_left).rawValue != 0 {
        foundSlopeRight = rightTile
      }
      if foundSlopeLeft == nil && rightTile.intersection(.slope_right).rawValue != 0 {
        foundSlopeLeft = rightTile
      }
      
      y += 1
      i += 1
    }
    
    return (left: foundSlopeLeft, right: foundSlopeRight)
  }
}
