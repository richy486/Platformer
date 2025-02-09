//
//  Map.swift
//  Platformer
//
//  Created by Richard Adem on 21/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

public struct Level {
  public var name: String
  public var blocks: [[Int]]

  public init(name: String, blocks: [[Int]]) {
    self.name = name
    self.blocks = blocks
  }

  public init() {
    name = "Level 1"
    print("Set blocks")
    blocks = [
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2],
      [0,0,P,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2],
      [0,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2],
      [0,0,0,0,0,128,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,34],
      [0,0,0,0,0,0,128,0,4096,0,2,0,0,0,0,0,0,0,0,0,0,0,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,1024,0,0,0,0,0,0,0,1024,0,0,0,0,0,34],
      [0,0,0,0,0,0,0,128,0,0,2,0,2,2,0,0,0,2048,0,0,0,0,1024,0,0,2,0,2,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,34],
      [0,0,0,0,0,0,0,0,128,0,2,0,2,0,2,0,0,0,0,0,0,0,1024,0,0,0,0,1024,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,1024,0,0,0,0,0,34],
      [0,0,0,0,0,0,0,0,4096,128,2,0,2,0,0,2,0,0,2048,2048,0,0,1024,0,0,1024,0,2,1024,1024,1024,0,0,0,1024,1024,0,0,0,0,0,0,10,10,10,10,10,1,10,34],
      [0,0,0,0,0,0,0,0,0,0,2,1,1,0,0,2,128,0,0,0,0,0,1024,2048,0,2,0,0,0,2,0,0,0,0,0,1024,1,0,0,0,1024,0,10,0,0,0,0,0,0,34],
      [0,0,0,0,0,0,0,0,0,0,2,128,1,2048,0,0,0,128,2048,0,0,2048,1024,0,0,0,0,0,1,0,0,0,0,0,0,1024,0,0,0,0,34,0,10,0,0,0,0,0,0,34],
      [0,0,2,1024,2,2,2,2,2,2,2,2,128,2048,1,2,2,2,2,1,2048,1,1,1024,0,1024,0,1,1,0,1024,0,0,0,0,1024,0,0,0,0,0,0,10,128,0,0,0,0,0,4],
      [0,0,0,1024,0,0,1,0,0,0,2,0,128,128,0,8192,8192,8192,0,0,0,0,1024,0,0,1024,1,1,0,2,0,0,0,0,1024,1024,0,0,0,1024,0,0,0,0,128,0,0,0,0,4],
      [0,0,2,1024,1024,0,2,2,2,0,2,0,1024,0,128,2048,1,2,0,2,0,1,1024,1024,1024,1,1024,0,1024,2,0,0,0,0,0,1024,0,0,0,10,0,0,0,0,0,128,0,0,0,4],
      [0,0,2,1024,0,0,0,0,0,2,2,2,2,0,2,128,0,0,2,2,2,1,128,1,1,1,0,0,0,2,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,34,10,0,0,34],
      [0,0,0,2,2,2,0,2,0,0,2,0,0,1,34,0,2048,2048,0,0,1,0,128,2,128,2048,2048,2048,2048,1,0,2,0,0,0,1024,0,0,0,0,0,0,0,0,0,34,34,1,0,34],
      [0,0,0,0,0,0,2,4,4,2,2,1,1,0,1,4096,34,128,1,2048,1,0,1024,128,1,1024,1024,1,1,1,1,0,2,0,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,4,34],
      [0,0,0,0,0,2,0,1,1,0,2,4,4,34,34,1,34,4,4,2048,2,1,1024,1,0,0,1024,0,1,2,0,0,0,10,2,10,0,0,0,2048,0,0,0,0,0,0,0,0,0,34],
      [0,0,0,0,2,2,2,2,2,2,2,1,0,0,34,2048,0,1,0,4,1,2,1024,1,1,0,0,1024,1,2,0,0,0,1,1,10,0,1,10,10,10,10,0,0,2048,1,2,2048,34,34],
      [0,0,2,2,2,2,2,0,1,8192,2,34,0,34,34,34,34,2,1,1,1,1,1024,1,2,1,0,0,1024,1,2,2,2,10,1,10,0,2,0,1024,0,10,34,34,34,34,0,0,0,34],
      [0,0,2,2,2,2,2,1,0,1,2,34,1,1,1,34,1,2,1,2,1,0,1024,0,0,1,1,1,1,1024,4,1,34,1,1,10,2,10,1024,1024,1024,10,10,10,10,10,0,0,0,34],
      [2,2,2,2,2,1024,2,1,2,1,2,1,8192,1,0,1,1,4,1,1,1,0,128,1,1,1,2,1,1,1024,128,1024,1,1,2048,1,0,4,0,1024,0,1024,1024,1024,1024,1024,0,0,1,34],
      [2,2,2,2,2,2,2,2,2,2,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34]
    ]
    print("Blocks done")

  }
}

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
