//
//  Player.swift
//  Platformer
//
//  Created by Richard Adem on 29/9/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

class Player: CollisionObject, ActorCarrier, UsesComponents, GravityComponent {
    
    internal(set) var _i = IntPoint.zero
    internal(set) var _f = CGPoint.zero
    internal(set) var vel: CGPoint = CGPoint.zero //velocity on x, y axis
    internal var fOld: CGPoint = CGPoint.zero
    internal(set) var lastGroundPosition: Int = Int.max
    internal(set) var slopesBelow: (left: TileTypeFlag?, right: TileTypeFlag?) = (nil, nil)
    internal(set) var inAir = false
    internal(set) var lastSlopeTilePoint: IntPoint?
    internal(set) var size = IntSize(width: 22, height: 25)
    internal(set) var direction: Direction = []
    
    internal var actors: [UUID: Actor] = [:]
    
    private var lockjump = false
    
    func restart() {
        lockjump = false
        inAir = true
        lastSlopeTilePoint = nil
        
        fOld = f
        
        vel = CGPoint.zero
        actors = [:]
    }
    
    func update(currentTime: TimeInterval, controlCommands: ControlCommands, level: Level) -> Level {
        
//        // Lets add gravity here
//        if inAir {
//            vel.y = cap(fallingVelocity: vel.y + AppState.shared.GRAVITATION)
//        }
        
        var level = level
        level = updateComponents(currentTime: currentTime, level: level)
        
        var movementDirectionX = CGFloat(0.0)
        if controlCommands.left == controlCommands.right {
            // Both left and right down or both left and right up
            movementDirectionX = 0.0
        } else if controlCommands.left {
            movementDirectionX = -1.0
        } else if controlCommands.right {
            movementDirectionX = 1.0
        }
        
        //jump pressed?
        if controlCommands.jump {
            // Jump!
            
            if !lockjump {
                if !inAir {
                    if tryFallingThroughPlatform(inDirectionX: movementDirectionX) {
                        
                    } else {
                        lastSlopeTilePoint = nil
                        
                        // This functions was called through tryFallingThroughPlatform in SMW
                        jump(inDirectionX: movementDirectionX, jumpModifier: 1.0)//, turbo: controlCommands.turbo)
                    }
                }
            }
        } else {
            enableFreeFall()
        }
        
        if movementDirectionX != 0.0 {
            accelerateX(movementDirectionX, turbo: controlCommands.turbo)
        } else {
            decreaseVelocity()
        }
        
        return update(currentTime: currentTime, level: level)
    }
    
    func update(currentTime: TimeInterval, level: Level) -> Level {
        var level = level
        fOld = f
        level = collisionDetection(level: level)
        
        for attached in actors {
            level = attached.value.update(currentTime: currentTime, level: level)
            attached.value.f = f
        }
        
        return level
    }
    
    // MARK: Movement
    
    // void CPlayer::accelerate(float direction)
    func accelerateX(_ direction: CGFloat, turbo: Bool) {
        
        var accelVel = CGPoint(x: AppState.shared.VELMOVINGADD, y: 0)
        accelVel.x *= direction
        vel += accelVel
        
        let maxVel: CGFloat
        if turbo {
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
        
        if abs(vel.x) > AppState.shared.VELMOVING && movementDirectionX != 0 {// && turbo {
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
}

extension Player: Collision {
    func tryCollide(withObject object: Actor) -> CollideResult {
        return .none
    }
}

extension Player: CollisionHorizontal {
    func collisionHorizontalResponse(vel: CGPoint) -> CGPoint {
        var vel = vel
        vel.x = 0
        return vel
    }
}
