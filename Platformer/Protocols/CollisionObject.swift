//
//  CollisionObject.swift
//  Platformer
//
//  Created by Richard Adem on 20/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

protocol CollisionObject: class {
    
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
    
    func update(currentTime: TimeInterval, level: Level) -> Level
}

extension CollisionObject where Self: Collision {
    
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
    
    func cap(fallingVelocity velY: CGFloat) -> CGFloat {
        if velY > MAXVELY {
            return MAXVELY
        }
        return velY
    }

    // Can change f in this function
    func collisionDetection(level: Level) -> Level {
        
        var level = level
        if AppState.shared.printCollisions {
            print("--- frame ---")
        }
        
        let targetPlayerPostition = CGPoint(x: f.x + vel.x, y: f.y + vel.y)
        
        slopesBelow = level.slopesBelow(position: targetPlayerPostition, level: level)
        
        let slopeResult = collision_slope(movePosition: f, velocity: vel, level: level, forTile: nil, force: lastSlopeTilePoint != nil)
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
                var s = IntPoint(x: Int(f.x + CGFloat(PW)/2 + vel.x), y: 0)
                if slopeDir.contains(.up) {
                    potentialPosition.y = CGFloat(slopeResult.collideTile.y * TILESIZE - PH - 1)
                    s.y = Int(potentialPosition.y) + PH
                } else if slopeDir.contains(.down) {
                    potentialPosition.y = CGFloat((slopeResult.collideTile.y + 1) * TILESIZE - PH - 1)
                    s.y = Int(potentialPosition.y) + PH + TILESIZE
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
                    f.y = CGFloat(yGround - inside - PH - 1)
                    
                    return level
                } else if t.contains(.slope_left) {
                    // ◿
                    f.x += vel.x
                    f.y = CGFloat((collideTile.y+1)*TILESIZE - s.x%TILESIZE - PH - 1)
                    return level
                }
                
            }
            self.lastSlopeTilePoint = nil
        }
        
        // X axis ⇄ Horizontal
        if vel.x > 0.01 {
            // Moving right
            
            let size = CGSize(width: PW, height: slopesBelow.right == nil ? PH : PH_SLOPE)
            
            var collide = false
            while f.x < targetPlayerPostition.x - COLLISION_GIVE && !collide {
                f.x = min(f.x + CGFloat(TILESIZE), targetPlayerPostition.x)
                let result = mapcolldet_moveHorizontal(movePosition: f, velocity: vel, horizontallyInDirection: 3, size: size, level: level)
                f = result.position
                vel = result.velocity
                collide = result.collide
                level = result.level
            }
            
        } else if vel.x < -0.01 {
            // Moving left
            
            let size = CGSize(width: PW, height: slopesBelow.left == nil ? PH : PH_SLOPE)
            
            var collide = false
            while f.x > targetPlayerPostition.x + COLLISION_GIVE && !collide {
                f.x = max(f.x - CGFloat(TILESIZE), targetPlayerPostition.x)
                let result = mapcolldet_moveHorizontal(movePosition: f, velocity: vel, horizontallyInDirection: 1, size: size, level: level)
                f = result.position
                vel = result.velocity
                collide = result.collide
                level = result.level
            }
        }
        
        // Y axis ⇅ Vertical if not on a slope
        if !slopeResult.collide {
            let iPlayerL = i.x / TILESIZE
            let iPlayerC = (i.x + HALFPW) / TILESIZE
            let iPlayerR = (i.x + PW) / TILESIZE
            
            let txl = slopesBelow.left == nil ? iPlayerL : iPlayerC
            let txc = iPlayerC
            let txr = slopesBelow.right == nil ? iPlayerR : iPlayerC
            
            var alignedBlockX = 0
            var unAlignedBlockX = 0
            var unAlignedBlockFX = CGFloat(0)
            
            let overlaptxl = (txl << 5) + TILESIZE + 1
            
            if i.x + HALFPW < overlaptxl {
                alignedBlockX = txl
                unAlignedBlockX = txr
                unAlignedBlockFX = CGFloat((txr << 5) - PW) - COLLISION_GIVE
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
                    let result = mapcolldet_moveDownward(movePosition: f,
                                                         oldPosition: fOld,
                                                         velocity: vel,
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
        
        return level
    }
}
