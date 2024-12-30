//
//  Pickup.swift
//  Platformer
//
//  Created by Richard Adem on 29/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

//import CoreGraphics
//import UIKit
import Foundation


public class Pickup: CollisionObject, UsesComponents, GravityComponent {
  public var _i = IntPoint.zero
  public var _f = Point.zero
  public var vel: Point = Point.zero //velocity on x, y axis
  public var fOld: Point = Point.zero
  public var lastGroundPosition: Int = Int.max
  public var slopesBelow: (left: TileTypeFlag?, right: TileTypeFlag?) = (nil, nil)
  public var inAir = true
  public var lastSlopeTilePoint: IntPoint?
  public var size = IntSize(width: 30, height: 30)
  public var direction: Direction = []
  
  public func update(currentTime: TimeInterval, level: Level) -> Level {
    
    //        // Lets add gravity here
    //        if inAir {
    //            vel.y = cap(fallingVelocity: vel.y + AppState.shared.GRAVITATION)
    //        }
    
    var level = level
    level = updateComponents(currentTime: currentTime, level: level)
    
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

extension Pickup: Collision {
  public func tryCollide(withObject object: Actor) -> CollideResult {
    
    if collisionDetection(withObject: object) {
      
      if let player = object as? Player {
        
        //player->fOldY + PH <= iy && player->iy + PH >= iy
        if player.fOld.y + Double(player.size.height) <= Double(i.y) && player.i.y + player.size.height >= i.y {
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

extension Pickup: CollisionHorizontal {
  public func collisionHorizontalResponse(vel: Point) -> Point {
    var vel = vel
    vel.x = vel.x * -1.0
    return vel
  }
}

extension Pickup: Droppable {
  func drop(by actor: Actor) {
    
    if actor.direction.contains(.right) {
      print("drop right")
      f.x = actor.f.x + Double(actor.size.width) + 1
      f.y = actor.f.y + Double(actor.size.height) - Double(size.height) - 1
      vel.x = AppState.shared.VELKICK
    } else if actor.direction.contains(.left) {
      print("drop left")
      f.x = actor.f.x - Double(size.width) - 1
      f.y = actor.f.y + Double(actor.size.height) - Double(size.height) - 1
      vel.x = -AppState.shared.VELKICK
    }
  }
}