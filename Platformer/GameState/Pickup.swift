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
    internal(set) var inAir = false
    internal(set) var lastSlopeTilePoint: IntPoint?
    
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
        if object.vel.x > 0 {
            vel.x = 5.0
        } else if object.vel.x < 0 {
            vel.x = -5.0
        }
    }
}

extension Pickup: Collision {
    func tryCollide(withObject object: MovingObject) {
        
        if collisionDetection(withObject: object) {
            kick(by: object)
        }
        
        
    }
}
