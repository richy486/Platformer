//
//  Player.swift
//  Platformer
//
//  Created by Richard Adem on 29/9/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

class Player: Collision, CollisionObject {
    
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
    
    internal(set) var lastGroundPosition: Int = Int.max
    internal(set) var slopesBelow: (left: TileTypeFlag?, right: TileTypeFlag?) = (nil, nil)
    
    
    private var lockjump = false
    internal(set) var inAir = false
    internal(set) var lastSlopeTilePoint: IntPoint?
    
    func restart() {
        lockjump = false
        inAir = true
        lastSlopeTilePoint = nil
        
        fOld = f
        
        vel = CGPoint.zero
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
        accelVel.x *= direction
        vel += accelVel
        
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
