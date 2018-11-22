//
//  Pickup.swift
//  Platformer
//
//  Created by Richard Adem on 29/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

class Pickup: CollisionObject {
    internal(set) var _i = IntPoint.zero
    internal(set) var _f = CGPoint.zero
    internal(set) var vel: CGPoint = CGPoint.zero //velocity on x, y axis
    internal var fOld: CGPoint = CGPoint.zero
    internal(set) var lastGroundPosition: Int = Int.max
    internal(set) var slopesBelow: (left: TileTypeFlag?, right: TileTypeFlag?) = (nil, nil)
    internal(set) var inAir = true
    internal(set) var lastSlopeTilePoint: IntPoint?
    internal(set) var size = IntSize(width: 30, height: 30)
    
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
    
    func kick(by object: MovingObject) {
        if object.f.x <= f.x {
            vel.x = 5.0
        } else if object.f.x > f.x {
            vel.x = -5.0
        }
    }
    func stop() {
        vel.x = 0
    }
}

extension Pickup: Collision {
    func tryCollide(withObject object: MovingObject) {
        
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

                    print("below: kick")
                    kick(by: player)

                }
            }
        }
    }
}

extension Pickup: CollisionHorizontal {
    func collisionHorizontalResponse(vel: CGPoint) -> CGPoint {
        var vel = vel
        vel.x = vel.x * -1.0
        return vel
    }
}
