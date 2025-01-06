//
//  Player.swift
//  Platformer
//
//  Created by Richard Adem on 29/9/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

//import CoreGraphics
//import UIKit
// import Foundation


public class Player: Actor, UsesComponents, GravityComponent {

  public override init() {
    super.init()
//    _i = IntPoint.zero
//    _f = Point.zero
    vel = Point.zero //velocity on x, y axis
    fOld = Point.zero
    lastGroundPosition = Int.max
    slopesBelow = (nil, nil)
    inAir = false
    lastSlopeTilePoint = nil
    size = IntSize(width: 22, height: 25)
    direction = []
    actors = [:]
  }

//  public var actors: [UUID: Actor] = [:]
  
  private var lockjump = false
  
  func restart() {
    lockjump = false
    inAir = true
    lastSlopeTilePoint = nil
    
    fOld = f
    
    vel = Point.zero
    actors = [:]
  }
  
  func update(currentTime: TimeInterval, controlCommands: ControlCommands, level: Level) -> Level {
    
    //        // Lets add gravity here
    //        if inAir {
    //            vel.y = cap(fallingVelocity: vel.y + AppState.shared.GRAVITATION)
    //        }
    
    var level = level
    level = updateComponents(currentTime: currentTime, level: level)
    
    var movementDirectionX = Double(0.0)
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
  
  public override func update(currentTime: TimeInterval, level: Level) -> Level {
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
  func accelerateX(_ direction: Double, turbo: Bool) {
    
    var accelVel = Point(x: AppState.shared.VELMOVINGADD, y: 0)
    accelVel.x *= direction
    vel += accelVel
    
    let maxVel: Double
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
  
  func jump(inDirectionX movementDirectionX: Double, jumpModifier: Double) {
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
  
  func tryFallingThroughPlatform(inDirectionX movementDirectionX: Double) -> Bool {
    
    // TODO: fall through code
    let fallThrough = false
    return fallThrough
  }

  public override func tryCollide(withObject object: Actor) -> CollideResult {
    return .none
  }
  public override func collisionHorizontalResponse(vel: Point) -> Point {
    var vel = vel
    vel.x = 0
    return vel
  }

  public override func drop(by actor: Actor) {}
}
