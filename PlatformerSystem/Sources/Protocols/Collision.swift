//
//  Collision.swift
//  Platformer
//
//  Created by Richard Adem on 20/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

public enum CollideResult {
  case none
  case collide
  case attach
}

public protocol Collision {
  
  func tryCollide(withObject object: Actor) -> CollideResult
}

// MARK: Map Collision
extension Collision where Self: CollisionHorizontal {
  
  // bool CPlayer::collision_slope(int sx, int sy, int &tsx;, int &tsy;)
  // https://web.archive.org/web/20100526071550/http://jnrdev.72dpiarmy.com:80/en/jnrdev2/
  // Shouldn't change f in this function, TODO: put into protocol extension
  func collisionSlope(movePosition position: Point, velocity: Point, size: IntSize, level: Level, forTile tilePosition: IntPoint? = nil, force: Bool = false) -> (position: Point, collide: Bool, collideTile: IntPoint) {
    
    let s = IntPoint(x: Int(position.x) + (size.width>>1) + Int(velocity.x),
                     y: Int(position.y) + size.height)
    
    var resultingPosition = position
    var collide = false
    let ts = IntPoint(x: s.x / TILESIZE, y: s.y / TILESIZE)
    let t = level.tile(point: ts)
    
    //if we found a slope we set align y to the slope.
    if t.contains(.slope_right) {
      // ◺
      if AppState.shared.printCollisions {
        print("◺: \(ts)")
      }
      let yGround = (ts.y+1) * TILESIZE       // y pixel coordinate of the ground of the tile
      let inside = TILESIZE - (s.x%TILESIZE)  // minus how far sx is inside the tile (16 pixels in the exapmle)
      
      // PH: minus the height (sx is located at the bottom of the player, but y is at the top)
      // -1: we don't want to stick in a tile, this would cause complications in the next frame
      resultingPosition.y = Double(yGround - inside - size.height - 1)
      
      if position.y + velocity.y >= resultingPosition.y || force{
        if AppState.shared.printCollisions {
          print("no slope ◺: \(ts)")
        }
        collide = true
      }
    } else if t.contains(.slope_left) {
      // ◿
      if AppState.shared.printCollisions {
        print("◿: \(ts)")
      }
      resultingPosition.y = Double((ts.y+1)*TILESIZE - s.x%TILESIZE - size.height - 1)
      if position.y + velocity.y >= resultingPosition.y  || force {
        if AppState.shared.printCollisions {
          print("no slope ◿: \(ts)")
        }
        collide = true
      }
    } else {
      if AppState.shared.printCollisions {
        print("no slope: \(ts)")
      }
    }
    
    return (resultingPosition, collide, ts)
  }
  
  // Shouldn't change f in this function, TODO: put into protocol extension
  func mapCollDetMoveHorizontal(movePosition position: Point,
                                velocity: Point,
                                horizontallyInDirection direction: Int,
                                adjustedSize: Size,
                                size: IntSize,
                                level: Level) -> (position: Point, velocity: Point, collide: Bool, level: Level) {
    
    var level = level
    
    // left 1
    // right 3
    var position = position
    var velocity = velocity
    
    //Could be optimized with bit shift >> 5
    let ty = Int(position.y) / TILESIZE
    let ty2 = Int(position.y + adjustedSize.height) / TILESIZE
    var tx = -1
    
    if direction == 1 {
      //moving left
      tx = Int(position.x) / TILESIZE;
    } else {
      //moving right
      tx = Int(position.x + adjustedSize.width) / TILESIZE;
    }
    
    let topTilePoint = IntPoint(x: tx, y: ty)
    let bottomTilePoint = IntPoint(x: tx, y: ty2)
    
    // Top tile
    var collide = false
    if level.collide(atPoint: topTilePoint, tileType: [.solid], direction: direction == 1 ? .left : .right) {
      collide = true
      if AppState.shared.printCollisions {
        print("--: \(IntPoint(x: tx, y: ty))")
      }
      // TODO: call Constants.kNotificationCollide
    } else if level.collide(atPoint: bottomTilePoint, tileType: [.solid], direction: direction == 1 ? .left : .right) {
      collide = true
      if AppState.shared.printCollisions {
        print("--: \(IntPoint(x: tx, y: ty2))")
      }
      // TODO: call Constants.kNotificationCollide
    }
    
    if collide {
      if direction == 1 {
        // move to the edge of the tile
        position.x = Double((tx << 5) + TILESIZE) + COLLISION_GIVE
      } else {
        // move to the edge of the tile (tile on the right -> mind the player width)
        position.x = Double((tx << 5) - size.width) - COLLISION_GIVE
      }
      
      if abs(velocity.x) > 0.0 {
        velocity = collisionHorizontalResponse(vel: velocity)
      }
      
    }
    return (position, velocity, collide, level)
  }
  
  // Shouldn't change f in this function, TODO: put into protocol extension
  func mapcolldet_moveUpward(movePosition position: Point,
                             txl: Int,
                             txc: Int,
                             txr: Int,
                             alignedBlockX: Int,
                             unAlignedBlockX: Int,
                             unAlignedBlockFX: Double,
                             level: Level) -> (position: Point, collide: Bool, level: Level) {
    var position = position
    var level = level
    
    // moving up
    let ty = Int(position.y) / TILESIZE
    
    //Player hit a solid
    if level.collide(atPoint: IntPoint(x: alignedBlockX, y: ty), tileType: [.solid], direction: .up) {
      //            print("collided top")
      if AppState.shared.printCollisions {
        print(" | top: \(IntPoint(x: txr, y: ty))")
      }
      position.y = Double((ty << 5) + TILESIZE) + COLLISION_GIVE
      
      return (position: position, collide: true, level: level)
    }
    
    //Player squeezed around the block
    if level.collide(atPoint: IntPoint(x: unAlignedBlockX, y: ty), tileType: [.solid], direction: .up, noTrigger: true) {
      print("squeezed")
      position.x = unAlignedBlockFX
    }
    
    return (position: position, collide: false, level: level)
  }
  
  // Shouldn't change f in this function, TODO: put into protocol extension
  func mapCollDetMoveDownward(movePosition position: Point,
                              oldPosition: Point,
                              velocity: Point,
                              size: IntSize,
                              txl: Int,
                              txc: Int,
                              txr: Int,
                              alignedBlockX: Int,
                              unAlignedBlockX: Int,
                              unAlignedBlockFX: Double,
                              level: Level) -> (position: Point, collide: Bool, inAir: Bool, groundPosition: Int, level: Level) {
    var position = position
    var level = level
    
    let ty = (Int(position.y) + size.height) / TILESIZE
    
    
    let collideTiles: TileTypeFlag = [.solid]
    let leftTilePos = IntPoint(x: txl, y: ty)
    let rightTilePos = IntPoint(x: txr, y: ty)
    
    // Can run over gaps
    let fGapSupport = (velocity.x >= AppState.shared.VELTURBOMOVING || velocity.x <= -AppState.shared.VELTURBOMOVING)
      && (level.isGap(point: leftTilePos) || level.isGap(point: rightTilePos))
    
    let fSolidTileUnderPlayerLeft = level.collide(atPoint: leftTilePos, tileType: collideTiles, direction: .down)
    let fSolidTileUnderPlayerRight = level.collide(atPoint: rightTilePos, tileType: collideTiles, direction: .down)
    let fSolidTileUnderPlayer = fSolidTileUnderPlayerLeft || fSolidTileUnderPlayerRight
    
    let fSolidOnTopUnderPlayerLeft = level.collide(atPoint: leftTilePos, tileType: [.solid_on_top], direction: .down)
    let fSolidOnTopUnderPlayerRight = level.collide(atPoint: rightTilePos, tileType: [.solid_on_top], direction: .down)
    let fSolidOnTopUnderPlayer = fSolidOnTopUnderPlayerLeft || fSolidOnTopUnderPlayerRight
    
    if fSolidTileUnderPlayerLeft || fSolidOnTopUnderPlayerLeft {
      if AppState.shared.printCollisions {
        print(" | d: \(IntPoint(x: txl, y: ty))")
      }
      // TODO: call Constants.kNotificationCollide
    }
    
    if fSolidTileUnderPlayerRight || fSolidOnTopUnderPlayerRight {
      if AppState.shared.printCollisions {
        print(" | d: \(IntPoint(x: txr, y: ty))")
      }
      // TODO: call Constants.kNotificationCollide
    }
    
    let inAir: Bool
    if (fSolidOnTopUnderPlayer || fGapSupport) && oldPosition.y + Double(size.height) <= Double(ty << 5) {
      
      // on ground
      // Deal with player down jumping through solid on top tiles
      
      // we were above the tile in the previous frame
      position.y = Double((ty << 5) - size.height) - COLLISION_GIVE
      inAir = false
      
    } else if fSolidTileUnderPlayer {
      // on ground
      position.y = Double((ty << 5) - size.height) - COLLISION_GIVE
      inAir = false
    } else {
      // falling (in air)
      inAir = true
    }
    
    return (position, !inAir, inAir, ty, level)
  }
}

// MARK: Object Collision

extension Collision {
  
  // bool coldec_obj2obj(CObject * o1, CObject * o2)
  func collisionDetection(withObject object: Actor) -> Bool {
    guard let o1 = self as? Actor else {
      return false
    }
    let o2 = object
    
    let o1r = o1.i.x + o1.size.width
    let o1b = o1.i.y + o1.size.height
    let o2r = o2.i.x + o2.size.width
    let o2b = o2.i.y + o2.size.height

    return
      o1.i.x < o2r &&
      o1r >= o2.i.x &&
      o1.i.y < o2b &&
      o1b >= o2.i.y
  }
}
