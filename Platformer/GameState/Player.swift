//
//  Player.swift
//  Platformer
//
//  Created by Richard Adem on 29/9/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

class Player {
    
    var startingPlayerPosition = CGPoint.zero
    
    private var _i = IntPoint.zero
    private(set) var i: IntPoint { //x, y coordinate (top left of the player rectangle)
        set {
            _f = newValue.cgPoint
            _i = newValue
        }
        get {
            return _i
        }
    }
    private var _f = CGPoint.zero
    private(set) var f: CGPoint {
        set {
            _f = newValue
            _i = newValue.intPoint
        }
        get {
            return _f
        }
    }
    
    private(set) var vel: CGPoint = CGPoint.zero //velocity on x, y axis
    private var fOld: CGPoint = CGPoint.zero
    private var oldvel: CGPoint = CGPoint.zero
    
    private(set) var lastGroundPosition: Int = Int.max
    
    
    private var lockjump = false
    private(set) var inair = false
    
    func restart() {
        lockjump = false
        inair = false
        
        f = startingPlayerPosition
        fOld = f
        
        vel = CGPoint.zero
        oldvel = CGPoint.zero
    }
    
    func update(keysDown: [KeyCode: Bool]) {
        var movementDirectionX = CGFloat(0.0)
        if keysDown[.left] == keysDown[.right] {
            // Both left and right down or both left and right up
            movementDirectionX = 0.0
        } else if keysDown[.left] == true {
            movementDirectionX = -1.0
        } else if keysDown[.right] == true {
            movementDirectionX = 1.0
        }
        
        //jump pressed?
        if keysDown[.a] == true {
            // Jump!
            
            if !lockjump {
                if !inair {
                    if tryFallingThroughPlatform(inDirectionX: movementDirectionX) {
                        
                    } else {
                        // This functions was called through tryFallingThroughPlatform in SMW
                        jump(inDirectionX: movementDirectionX, jumpModifier: 1.0)
                    }
                }
            }
        } else {
            enableFreeFall()
        }
        
        if movementDirectionX != 0.0 {
            accelerateX(movementDirectionX)
        } else {
            decreaseVelocity()
        }
        
        fOld = f
        collision_detection_map()
    }
    
    // MARK: Movement
    
    // void CPlayer::accelerate(float direction)
    func accelerateX(_ direction: CGFloat) {
        
        
        vel.x += AppState.shared.VELMOVINGADD * direction
        let maxVel: CGFloat
        if keysDown[.shift] == true {
            maxVel = AppState.shared.VELTURBOMOVING
        } else {
            maxVel = AppState.shared.VELMOVING
        }
        
        
        
        if abs(vel.x) > maxVel {
            vel.x = maxVel * direction
        }
    }
    
    // for testing
    //    func accelerateY(_ direction: CGFloat) {
    //        vel.y += AppState.shared.VELMOVINGADD * direction
    //        let maxVel: CGFloat = AppState.shared.VELMOVING
    //
    //        if abs(vel.y) > maxVel {
    //            vel.y = maxVel * direction
    //        }
    //    }
    
    func decreaseVelocity() {
        if vel.x > 0.0 {
            vel.x -= VELMOVINGFRICTION
            
            if vel.x < 0.0 {
                vel.x = 0.0
            }
        } else if vel.x < 0.0 {
            vel.x += VELMOVINGFRICTION
            
            if vel.x > 0.0 {
                vel.x = 0.0
            }
        }
    }
    
    func jump(inDirectionX movementDirectionX: CGFloat, jumpModifier: CGFloat) {
        lockjump = true
        
        if abs(vel.x) > AppState.shared.VELMOVING && movementDirectionX != 0 && keysDown[.shift] == true {
            vel.y = -AppState.shared.VELTURBOJUMP * jumpModifier
        } else {
            vel.y = -AppState.shared.VELJUMP * jumpModifier
        }
        
        
        inair = true;
    }
    
    func enableFreeFall() {
        
        lockjump = false //the jump key is not pressed: the player may jump again if he is on the ground
        if vel.y < -AppState.shared.VELSTOPJUMP {
            vel.y = -AppState.shared.VELSTOPJUMP
        }
    }
    
    func tryFallingThroughPlatform(inDirectionX movementDirectionX: CGFloat) -> Bool {
        
        // TODO: fall through code
        let fallThrough = false
        return fallThrough
    }
    
    // MARK: Collisions
    
    func collision_detection_map() {
        
        // Lets add gravity here
        vel.y = cap(fallingVelocity: vel.y + AppState.shared.GRAVITATION)
        let targetPlayerPostition = CGPoint(x: f.x + vel.x, y: f.y + vel.y)
        
        //  x axis (--)
        
        if f.y + CGFloat(PH) >= 0.0 {
            if vel.x > 0.01 {
                // Moving right
                
                var collide = false
                while f.x < targetPlayerPostition.x - COLLISION_GIVE && !collide {
                    f.x = min(f.x + CGFloat(TILESIZE), targetPlayerPostition.x)
                    let result = mapcolldet_move(movePosition: f, horizontallyInDirection: 3)
                    f = result.position
                    collide = result.collide
                }
                
            } else if vel.x < -0.01 {
                // Moving left
                var collide = false
                while f.x > targetPlayerPostition.x + COLLISION_GIVE && !collide {
                    f.x = max(f.x - CGFloat(TILESIZE), targetPlayerPostition.x)
                    let result = mapcolldet_move(movePosition: f, horizontallyInDirection: 1)
                    f = result.position
                    collide = result.collide
                }
            }
        }
        
        //  then y axis (|)
        let iPlayerL = i.x
        let iPlayerC = i.x + HALFPW
        let iPlayerR = i.x + PW
        
        let txl = iPlayerL / TILESIZE
        let txc = iPlayerC / TILESIZE
        let txr = iPlayerR / TILESIZE
        
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
                    unAlignedBlockFX: unAlignedBlockFX)
                collide = result.collide
                potentialPosition = result.position
            }
            if collide && vel.y < 0.0 {
                print("bounce")
                vel.y = -vel.y * BOUNCESTRENGTH
            }
            f = potentialPosition
        } else {
            //moving down / on ground
            var collide = false
            var potentialPosition = f
            var inAir = inair
            var groundPosition: Int = lastGroundPosition
            while f.y < targetPlayerPostition.y - COLLISION_GIVE && !collide {
                f.y = min(f.y + CGFloat(TILESIZE), targetPlayerPostition.y)
                let result = mapcolldet_moveDownward(movePosition: f,
                                                     txl: txl,
                                                     txc: txc,
                                                     txr: txr,
                                                     alignedBlockX: alignedBlockX,
                                                     unAlignedBlockX: unAlignedBlockX,
                                                     unAlignedBlockFX: unAlignedBlockFX)
                collide = result.collide
                potentialPosition = result.position
                inAir = result.inAir
                groundPosition = result.groundPosition
            }
            f = potentialPosition
            inair = inAir
            
            if collide && abs(lastGroundPosition - groundPosition) > 1 {
                lastGroundPosition = groundPosition
            }
        }
        
        // Reset gravity if on the ground
        if !inair {
            vel.y = AppState.shared.GRAVITATION
        }
    }
    
    func mapcolldet_move(movePosition position: CGPoint, horizontallyInDirection direction: Int) -> (position: CGPoint, collide: Bool) {
        // left 1
        // right 3
        var position = position
        
        //Could be optimized with bit shift >> 5
        let ty = Int(position.y) / TILESIZE
        let ty2 = (Int(position.y) + PH) / TILESIZE
        var tx = -1
        
        if direction == 1 {
            //moving left
            tx = Int(position.x) / TILESIZE;
        } else {
            //moving right
            tx = (Int(position.x) + PW) / TILESIZE;
        }
        
        let topTilePoint = IntPoint(x: tx, y: ty)
        let bottomTilePoint = IntPoint(x: tx, y: ty2)
        
        // Top tile
        var collide = false
        if Map.collide(atPoint: topTilePoint, tileType: [.solid], direction: direction == 1 ? .left : .right) {
            collide = true
            NotificationCenter.default.post(name: Constants.kNotificationCollide,
                                            object: self,
                                            userInfo: [Constants.kCollideXPosition: CGPoint(x: tx * TILESIZE, y: ty * TILESIZE)])
        } else if Map.collide(atPoint: bottomTilePoint, tileType: [.solid], direction: direction == 1 ? .left : .right) {
            collide = true
            NotificationCenter.default.post(name: Constants.kNotificationCollide,
                                            object: self,
                                            userInfo: [Constants.kCollideXPosition: CGPoint(x: tx * TILESIZE, y: ty2 * TILESIZE)])
        }
        
        if collide {
            if direction == 1 {
                // move to the edge of the tile
                position.x = CGFloat((tx << 5) + TILESIZE) + COLLISION_GIVE
            } else {
                // move to the edge of the tile (tile on the right -> mind the player width)
                position.x = CGFloat((tx << 5) - PW) - COLLISION_GIVE
            }
            
            if abs(vel.x) > 0.0 {
                vel.x = 0.0
            }
            if abs(oldvel.x) > 0.0 {
                oldvel.x = 0.0
            }
        }
        return (position, collide)
    }
    
    
    func mapcolldet_moveUpward(movePosition position: CGPoint,
                               txl: Int,
                               txc: Int,
                               txr: Int,
                               alignedBlockX: Int,
                               unAlignedBlockX: Int,
                               unAlignedBlockFX: CGFloat) -> (position: CGPoint, collide: Bool) {
        var position = position
        
        // moving up
        let ty = Int(position.y) / TILESIZE
        
        //Player hit a solid
        if Map.collide(atPoint: IntPoint(x: alignedBlockX, y: ty), tileType: [.solid], direction: .up) {
            print("collided top")
            position.y = CGFloat((ty << 5) + TILESIZE) + COLLISION_GIVE
            
            return (position: position, collide: true)
        }
        
        //Player squeezed around the block
        if Map.collide(atPoint: IntPoint(x: unAlignedBlockX, y: ty), tileType: [.solid], direction: .up, noTrigger: true) {
            print("squeezed")
            position.x = unAlignedBlockFX
        }
        
        inair = true
        
        return (position: position, collide: false)
    }
    
    func mapcolldet_moveDownward(movePosition position: CGPoint,
                                 txl: Int,
                                 txc: Int,
                                 txr: Int,
                                 alignedBlockX: Int,
                                 unAlignedBlockX: Int,
                                 unAlignedBlockFX: CGFloat) -> (position: CGPoint, collide: Bool, inAir: Bool, groundPosition: Int) {
        
        var position = position
        
        let ty = (Int(position.y) + PH) / TILESIZE
        
        
        let collideTiles: TileTypeFlag = [.solid]
        let leftTilePos = IntPoint(x: txl, y: ty)
        let rightTilePos = IntPoint(x: txr, y: ty)
        
        // Can run over gaps
        let fGapSupport = (vel.x >= AppState.shared.VELTURBOMOVING || vel.x <= -AppState.shared.VELTURBOMOVING)
            && (Map.isGap(point: leftTilePos) || Map.isGap(point: rightTilePos))
        
        let fSolidTileUnderPlayerLeft = Map.collide(atPoint: leftTilePos, tileType: collideTiles, direction: .down)
        let fSolidTileUnderPlayerRight = Map.collide(atPoint: rightTilePos, tileType: collideTiles, direction: .down)
        let fSolidTileUnderPlayer = fSolidTileUnderPlayerLeft || fSolidTileUnderPlayerRight
        
        let fSolidOnTopUnderPlayerLeft = Map.collide(atPoint: leftTilePos, tileType: [.solid_on_top], direction: .down)
        let fSolidOnTopUnderPlayerRight = Map.collide(atPoint: rightTilePos, tileType: [.solid_on_top], direction: .down)
        let fSolidOnTopUnderPlayer = fSolidOnTopUnderPlayerLeft || fSolidOnTopUnderPlayerRight
        
        if fSolidTileUnderPlayerLeft || fSolidOnTopUnderPlayerLeft {
            NotificationCenter.default.post(name: Constants.kNotificationCollide,
                                            object: self,
                                            userInfo: [Constants.kCollideYLeftPosition: CGPoint(x: txl * TILESIZE, y: ty * TILESIZE)])
        }

        if fSolidTileUnderPlayerRight || fSolidOnTopUnderPlayerRight {
            NotificationCenter.default.post(name: Constants.kNotificationCollide,
                                            object: self,
                                            userInfo: [Constants.kCollideYRightPosition: CGPoint(x: txr * TILESIZE, y: ty * TILESIZE)])
        }
        
        let inAir: Bool
        if (fSolidOnTopUnderPlayer || fGapSupport) && fOld.y + CGFloat(PH) <= CGFloat(ty << 5) {
            
            // on ground
            // Deal with player down jumping through solid on top tiles
            
            // we were above the tile in the previous frame
            position.y = CGFloat((ty << 5) - PH) - COLLISION_GIVE
            inAir = false
            
        } else if fSolidTileUnderPlayer {
            // on ground
            position.y = CGFloat((ty << 5) - PH) - COLLISION_GIVE
            inAir = false
        } else {
            // falling (in air)
            inAir = true
        }
        
        return (position, !inAir, inAir, ty)
    }
    
    // ObjectBase.h
    private func cap(fallingVelocity vel: CGFloat) -> CGFloat {
        if vel > MAXVELY {
            return MAXVELY
        }
        return vel
    }
}
