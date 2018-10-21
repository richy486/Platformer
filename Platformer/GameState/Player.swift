//
//  Player.swift
//  Platformer
//
//  Created by Richard Adem on 29/9/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

class Player: Collision, CollisionObject {
    
    var startingPlayerPosition = CGPoint.zero
    
    private var _i = IntPoint.zero
    internal(set) var i: IntPoint { //x, y coordinate (top left of the player rectangle)
        set {
            _f = newValue.cgPoint
            _i = newValue
        }
        get {
            return _i
        }
    }
    private var _f = CGPoint.zero
    internal(set) var f: CGPoint {
        set {
            _f = newValue
            _i = newValue.intPoint
        }
        get {
            return _f
        }
    }
    
    internal(set) var vel: CGPoint = CGPoint.zero //velocity on x, y axis
    internal var fOld: CGPoint = CGPoint.zero
//    private var oldvel: CGPoint = CGPoint.zero
    
    internal(set) var lastGroundPosition: Int = Int.max
//    private var slope_prevtile = IntPoint.zero
    internal(set) var slopesBelow: (left: TileTypeFlag?, right: TileTypeFlag?) = (nil, nil)
    
    
    private var lockjump = false
    internal(set) var inAir = false
    internal(set) var lastSlopeTilePoint: IntPoint?
    
//    private enum Direction: Int {
////        case notIn = -1     // -1 ... we didn't move from slope to slope
////        case exitDown = 0   //  0 ... we left a slope after moving down
////        case exitUp = 1     //  1 ... we left a slope after moving up
//        case stationary
//
//        case up
//        case down
//        case left
//        case right
//
//        case upLeft
//        case upRight
//        case downLeft
//        case doenRight
//    }
    
    func restart() {
        lockjump = false
        inAir = true//false
        lastSlopeTilePoint = nil
        
        f = startingPlayerPosition
        fOld = f
        
        vel = CGPoint.zero
//        oldvel = CGPoint.zero
    }
    
    func update(keysDown: [KeyCode: Bool]) {
        
        // Lets add gravity here
        if inAir {
            vel.y = cap(fallingVelocity: vel.y + AppState.shared.GRAVITATION)
        }
        
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
                if !inAir {
                    if tryFallingThroughPlatform(inDirectionX: movementDirectionX) {
                        
                    } else {
                        lastSlopeTilePoint = nil
                        
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
        
        var accelVel = CGPoint(x: AppState.shared.VELMOVINGADD, y: 0)
        #if PUSHUPSLOPE
            if let lastSlopeTilePoint = lastSlopeTilePoint {
                let tile = Map.tile(point: lastSlopeTilePoint)
                let sDirection = Map.slopeDirection(forVelocity: CGPoint(x: AppState.shared.VELMOVINGADD * direction, y: 0),
                                                andTile: tile)
                accelVel = accelVel.rotated(radians: sDirection.radians)
                vel += accelVel
            } else {
                accelVel.x *= direction
                vel += accelVel
            }
        #else
            accelVel.x *= direction
            vel += accelVel
        #endif
        
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
        
        
        inAir = true;
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
    
    // This only works for 45º slopes
    private var slopeMoveDirection: Direction {
        var direction: Direction = .stationary
        if let lastSlopeTile = lastSlopeTilePoint {
            if Map.tile(point: lastSlopeTile).intersection(.slope_right).rawValue != 0 {
                direction = vel.x > 0
                    ? .downRight
                    : .upRight
                
            } else if Map.tile(point: lastSlopeTile).contains(.slope_left) {
                direction = vel.x < 0
                    ? .downLeft
                    : .upLeft
            }
        }
        return direction
    }
    
    // ObjectBase.h
    private func cap(fallingVelocity velY: CGFloat) -> CGFloat {
        if velY > MAXVELY {
            return MAXVELY
        }
        return velY
    }
}
