//
//  Piggy.swift
//  Platformer
//
//  Created by Richard Adem on 1/12/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

class Piggy: CollisionObject {
    internal(set) var _i = IntPoint.zero
    internal(set) var _f = CGPoint.zero
    internal(set) var vel: CGPoint = CGPoint.zero //velocity on x, y axis
    internal var fOld: CGPoint = CGPoint.zero
    internal(set) var lastGroundPosition: Int = Int.max
    internal(set) var slopesBelow: (left: TileTypeFlag?, right: TileTypeFlag?) = (nil, nil)
    internal(set) var inAir = true
    internal(set) var lastSlopeTilePoint: IntPoint?
    internal(set) var size = IntSize(width: 28, height: 22)
    internal(set) var direction: Direction = []
    
    func update(currentTime: TimeInterval, level: Level) -> Level {
        
        // Lets add gravity here
        if inAir {
            vel.y = cap(fallingVelocity: vel.y + AppState.shared.GRAVITATION)
        }
        
        var level = level
        fOld = f
        level = collisionDetection(level: level)
        return level
    }
    
    func kick(by object: Actor) {
        if object.f.x <= f.x {
            vel.x = AppState.shared.VELKICK
        } else if object.f.x > f.x {
            vel.x = -AppState.shared.VELKICK
        }
    }
    func stop() {
        vel.x = 0
    }
}

extension Piggy: Collision {
    func tryCollide(withObject object: Actor) -> CollideResult {
        
        if collisionDetection(withObject: object) {
            
            if let player = object as? Player {
                
                //player->fOldY + PH <= iy && player->iy + PH >= iy
                if player.fOld.y + CGFloat(player.size.height) <= CGFloat(i.y) && player.i.y + player.size.height >= i.y {
                    // was hit on top
                    
                    
                    if vel.x != 0.0 {
                        // Moving
                        print("top: stop")
                        player.jump(inDirectionX: 0, jumpModifier: 1.0)
                        stop()
                    } else {
                        // Stopped
                        print("top: kick")
                        kick(by: player)
                        
                    }
                } else {
                    // was hit below
                    
                    if vel.x != 0.0 {
                        // Moving
                        print("below: kick")
                        kick(by: player)
                    } else if abs(player.vel.x) > AppState.shared.VELMOVING {
                        // Stopped & player running
                        
                        print("below: attach")
                        return .attach
                    } else {
                        // Stopped
                        
                        print("below: kick")
                        kick(by: player)
                    }
                    
                }
            }
            return .collide
        }
        return .none
    }
}

extension Piggy: CollisionHorizontal {
    func collisionHorizontalResponse(vel: CGPoint) -> CGPoint {
        var vel = vel
        vel.x = vel.x * -1.0
        return vel
    }
}

extension Piggy: Droppable {
    func drop(by actor: Actor) {
        
        if actor.direction.contains(.right) {
            print("drop right")
            f.x = actor.f.x + CGFloat(actor.size.width) + 1
            f.y = actor.f.y + CGFloat(actor.size.height) - CGFloat(size.height) - 1
            vel.x = AppState.shared.VELKICK
        } else if actor.direction.contains(.left) {
            print("drop left")
            f.x = actor.f.x - CGFloat(size.width) - 1
            f.y = actor.f.y + CGFloat(actor.size.height) - CGFloat(size.height) - 1
            vel.x = -AppState.shared.VELKICK
        }
    }
}
