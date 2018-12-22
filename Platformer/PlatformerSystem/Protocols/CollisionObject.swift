//
//  CollisionObject.swift
//  Platformer
//
//  Created by Richard Adem on 20/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

public protocol CollisionObject: class {
    
    var f: CGPoint { get set }
    var i: IntPoint { get set }
    var _f: CGPoint { get set }
    var _i: IntPoint { get set }
    var fOld: CGPoint { get set }
    var vel: CGPoint { get set }
    var inAir: Bool { get set }
    var lastSlopeTilePoint: IntPoint? { get set }
    var slopesBelow: (left: TileTypeFlag?, right: TileTypeFlag?) { get set }
    var lastGroundPosition: Int { get set }
    var size: IntSize { get }
    var direction: Direction { get set }
    
    func update(currentTime: TimeInterval, level: Level) -> Level
}

public extension CollisionObject where Self: Collision, Self: CollisionHorizontal {
    
    // MARK: Helper functions and vars
    var f: CGPoint {
        set {
            _f = newValue
            _i = newValue.intPoint
        }
        get {
            return _f
        }
    }
    var i: IntPoint { //x, y coordinate (top left of the player rectangle)
        set {
            _f = newValue.cgPoint
            _i = newValue
        }
        get {
            return _i
        }
    }
    
    private func updateDirection() {
        
        var direction: Direction = []
        if vel.x > 0.0 {
            direction = direction.union(.right)
        } else if vel.x < 0.0 {
            direction = direction.union(.left)
        } else {
            // Keep last X direction
            direction = self.direction.intersection([.left, .right])
        }
        
        // Always has to have a direction.
        // Although before the first frame finishes this check wont be called
        // Face the right for right to left levels
        if direction.contains(.right) == false && direction.contains(.left) == false {
            direction = direction.union(.right)
        }
        
        if vel.y < 0.0 {
            direction = direction.union(.up)
        } else if vel.y > 0.0 {
            direction = direction.union(.down)
        }
        
        self.direction = direction
    }
    
    func cap(fallingVelocity velY: CGFloat) -> CGFloat {
        if velY > MAXVELY {
            return MAXVELY
        }
        return velY
    }
    
//    let PH_SLOPE = PH - HALFPW - 1
    var heightSlope: Int {
        return size.height - (size.width/2) - 1
    }
    
    // MARK: Collision

    // Can change f in this function
    func collisionDetection(level: Level) -> Level {
        
        var level = level
        if AppState.shared.printCollisions {
            print("--- frame ---")
        }
        
        let targetPlayerPostition = CGPoint(x: f.x + vel.x, y: f.y + vel.y)
        
        slopesBelow = level.slopesBelow(position: targetPlayerPostition, size: size, level: level)
        
        let slopeResult = collisionSlope(movePosition: f, velocity: vel, size: size, level: level, forTile: nil, force: lastSlopeTilePoint != nil)
        if slopeResult.collide {
            f.y = slopeResult.position.y
            inAir = false
            lastSlopeTilePoint = slopeResult.collideTile
            vel.y = CGFloat(1) // What is this for?
        } else if let lastSlopeTilePoint = lastSlopeTilePoint {
            let lastSlopeTile = level.tile(point: lastSlopeTilePoint)
            let slopeDir = level.slopeDirection(forVelocity: vel, andTile: lastSlopeTile)
            
            // We know it's diagonal by now
            if slopeDir != .stationary {
                var potentialPosition = f
                var s = IntPoint(x: Int(f.x + CGFloat(size.width)/2 + vel.x), y: 0)
                if slopeDir.contains(.up) {
                    potentialPosition.y = CGFloat(slopeResult.collideTile.y * TILESIZE - size.height - 1)
                    s.y = Int(potentialPosition.y) + size.height
                } else if slopeDir.contains(.down) {
                    potentialPosition.y = CGFloat((slopeResult.collideTile.y + 1) * TILESIZE - size.height - 1)
                    s.y = Int(potentialPosition.y) + size.height + TILESIZE
                }
                
                let collideTile = IntPoint(x: s.x / TILESIZE, y: s.y / TILESIZE)
                
                let t = level.tile(point: collideTile)
                
                if t.contains(.slope_right) {
                    // ◺
                    let yGround = (collideTile.y+1) * TILESIZE       // y pixel coordinate of the ground of the tile
                    let inside = TILESIZE - (s.x%TILESIZE)  // minus how far sx is inside the tile (16 pixels in the exapmle)
                    
                    f.x += vel.x
                    // PH: minus the height (sx is located at the bottom of the player, but y is at the top)
                    // -1: we don't want to stick in a tile, this would cause complications in the next frame
                    f.y = CGFloat(yGround - inside - size.height - 1)
                    
                    return level
                } else if t.contains(.slope_left) {
                    // ◿
                    f.x += vel.x
                    f.y = CGFloat((collideTile.y+1)*TILESIZE - s.x%TILESIZE - size.height - 1)
                    return level
                }
                
            }
            self.lastSlopeTilePoint = nil
        }
        
        // X axis ⇄ Horizontal
        if vel.x > 0.01 {
            // Moving right
            
            let adjustedSize = CGSize(width: size.width, height: slopesBelow.right == nil ? size.height : heightSlope)
            
            var collide = false
            while f.x < targetPlayerPostition.x - COLLISION_GIVE && !collide {
                f.x = min(f.x + CGFloat(TILESIZE), targetPlayerPostition.x)
                let result = mapCollDetMoveHorizontal(movePosition: f, velocity: vel, horizontallyInDirection: 3, adjustedSize: adjustedSize, size: size, level: level)
                f = result.position
                vel = result.velocity
                collide = result.collide
                level = result.level
            }
            
        } else if vel.x < -0.01 {
            // Moving left
            
            let adjustedSize = CGSize(width: size.width, height: slopesBelow.left == nil ? size.height : heightSlope)
            
            var collide = false
            while f.x > targetPlayerPostition.x + COLLISION_GIVE && !collide {
                f.x = max(f.x - CGFloat(TILESIZE), targetPlayerPostition.x)
                let result = mapCollDetMoveHorizontal(movePosition: f, velocity: vel, horizontallyInDirection: 1, adjustedSize: adjustedSize, size: size, level: level)
                f = result.position
                vel = result.velocity
                collide = result.collide
                level = result.level
            }
        }
        
        // Y axis ⇅ Vertical if not on a slope
        if !slopeResult.collide {
            let iPlayerL = i.x / TILESIZE
            let iPlayerC = (i.x + (size.width/2)) / TILESIZE
            let iPlayerR = (i.x + size.width) / TILESIZE
            
            let txl = slopesBelow.left == nil ? iPlayerL : iPlayerC
            let txc = iPlayerC
            let txr = slopesBelow.right == nil ? iPlayerR : iPlayerC
            
            var alignedBlockX = 0
            var unAlignedBlockX = 0
            var unAlignedBlockFX = CGFloat(0)
            
            let overlaptxl = (txl << 5) + TILESIZE + 1
            
            if i.x + (size.width/2) < overlaptxl {
                alignedBlockX = txl
                unAlignedBlockX = txr
                unAlignedBlockFX = CGFloat((txr << 5) - size.width) - COLLISION_GIVE
            } else {
                alignedBlockX = txr
                unAlignedBlockX = txl
                unAlignedBlockFX = CGFloat((txl << 5) + TILESIZE) + COLLISION_GIVE
            }
            
            if vel.y < -0.01 {
                
                //moving up
                var collide = false
                var potentialPosition = f
                while f.y > targetPlayerPostition.y + COLLISION_GIVE && !collide {
                    f.y = max(f.y - CGFloat(TILESIZE), targetPlayerPostition.y)
                    let result = mapcolldet_moveUpward(movePosition: f,
                                                       txl: txl,
                                                       txc: txc,
                                                       txr: txr,
                                                       alignedBlockX: alignedBlockX,
                                                       unAlignedBlockX: unAlignedBlockX,
                                                       unAlignedBlockFX: unAlignedBlockFX,
                                                       level: level)
                    collide = result.collide
                    potentialPosition = result.position
                    level = result.level
                }
                if collide && vel.y < 0.0 {
                    print("bounce")
                    vel.y = -vel.y * BOUNCESTRENGTH
                }
                f = potentialPosition
            } else {
                //moving down / on ground
                var collide = false
                var potentialPosition = self.f
                var inAir = self.inAir
                var groundPosition: Int = lastGroundPosition
                while f.y < targetPlayerPostition.y - COLLISION_GIVE && !collide {
                    f.y = min(f.y + CGFloat(TILESIZE), targetPlayerPostition.y)
                    let result = mapCollDetMoveDownward(movePosition: f,
                                                         oldPosition: fOld,
                                                         velocity: vel,
                                                         size: size,
                                                         txl: txl,
                                                         txc: txc,
                                                         txr: txr,
                                                         alignedBlockX: alignedBlockX,
                                                         unAlignedBlockX: unAlignedBlockX,
                                                         unAlignedBlockFX: unAlignedBlockFX,
                                                         level: level)
                    collide = result.collide
                    potentialPosition = result.position
                    inAir = result.inAir
                    groundPosition = result.groundPosition
                    level = result.level
                }
                self.f = potentialPosition
                self.inAir = inAir
                
                if collide && abs(lastGroundPosition - groundPosition) > 1 {
                    lastGroundPosition = groundPosition
                }
            }
        }
        
        updateDirection()
        
        return level
    }
}
