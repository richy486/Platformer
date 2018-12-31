//
//  JSItem.swift
//  Platformer macOS
//
//  Created by Richard Adem on 22/12/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation
import JavaScriptCore

let script =
"""
var VELMOVING = 4.0;
var VELKICK = 5.0;

var VELJUMP = 9.0;          //velocity for jumping
var VELSTOPJUMP = 5.0;
var VELTURBOJUMP = 10.2;

var collideWithPlayer = function(self, player) {

  //  console.log('size: ' + player.size);

  if (player.fOld.y + player.height <= self.f.y && player.f.y + player.height >= self.f.y) {
    if (self.vel.x !== 0.0) {
      // Moving
      console.log('top: stop');
      player = jump(player, 0, 1.0);
      self = stop(self);
    } else {
      console.log('top: kick');
      self = kick(self, player);
    }
  } else {
    // was hit below
    if (self.vel.x !== 0.0) {
      // Moving
      console.log('below: kick');
      self = kick(self, player);
    } else if (Math.abs(player.vel.x) > VELMOVING) {
      // Stopped & player running
            
      console.log('below: attach');
      return [self, player, "attach"];

    } else {
      console.log('below: kick');
      self = kick(self, player);
    }
  }

  return [self, player, "none"];
}

var kick = function(self, other) {
  console.log('will kick with: ' + VELKICK);
  var vel = self.vel;
  if (other.f.x <= self.f.x) {
    vel.x = VELKICK;
    console.log('kick right ' + self.vel.x);

  } else if (other.f.x > self.f.x) {
    vel.x = -VELKICK;
    console.log('kick left ' + self.vel.x);
  } else {
    console.log('no kick');
  }
  self.vel = vel;
  console.log('vel ' + vel.x);
  console.log('self vel ' + self.vel.x);
  return self;

}

var jump = function(actor, inDirectionX, jumpModifier) {
  console.log('will JUMP');
  var vel = actor.vel;
  if (Math.abs(actor.vel.x) > VELMOVING && inDirectionX != 0) {
    vel.y = -VELTURBOJUMP * jumpModifier;
  } else {
    vel.y = -VELJUMP * jumpModifier;
  }
  console.log('jump vel ' + vel.y);
  actor.vel = vel;
  return actor;
}

var stop = function(actor) {
  var vel = actor.vel;
  vel.x = 0
  actor.vel = vel;
  return actor;
}

"""

public class JSItem: CollisionObject, UsesComponents, GravityComponent {
  public var _i = IntPoint.zero
  public var _f = CGPoint.zero
  public var vel: CGPoint = CGPoint.zero //velocity on x, y axis
  public var fOld: CGPoint = CGPoint.zero
  public var lastGroundPosition: Int = Int.max
  public var slopesBelow: (left: TileTypeFlag?, right: TileTypeFlag?) = (nil, nil)
  public var inAir = true
  public var lastSlopeTilePoint: IntPoint?
  public var size = IntSize(width: 28, height: 22)
  public var direction: Direction = []
  
  private let context = JSContext()!
  private var collideWithPlayerJS: JSValue!
  
  init() {
    
    // JS: console.log("a: " + a);
    context.evaluateScript("var console = { log: function(message) { _consoleLog(message) } }")
    let consoleLog: @convention(block) (String) -> Void = { message in
      print("console.log: " + message)
    }
    context.setObject(unsafeBitCast(consoleLog, to: AnyObject.self),
                      forKeyedSubscript: "_consoleLog" as (NSCopying & NSObjectProtocol))
    
    // Actor JS
    context.setObject(ActorJS.self, forKeyedSubscript: "Actor" as NSCopying & NSObjectProtocol)
    
    // Script
    context.evaluateScript(script)
    collideWithPlayerJS = context.objectForKeyedSubscript("collideWithPlayer")!
    
    context.exceptionHandler = { context, value in
      print("exception: \(String(describing: context)), \(String(describing: value))")
    }
  }
  
  public func update(currentTime: TimeInterval, level: Level) -> Level {
    
    var level = level
    level = updateComponents(currentTime: currentTime, level: level)
    
    fOld = f
    level = collisionDetection(level: level)
    return level
  }
}

extension JSItem: Collision {
  
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
  
  
  public func tryCollide(withObject object: Actor) -> CollideResult {
    
    if collisionDetection(withObject: object) {
      
      if let player = object as? Player {
        
        let selfActorJS = ActorJS(f: f, vel: vel, fOld: fOld, width: size.width, height: size.height)
        let playerActorJS = ActorJS(f: player.f, vel: player.vel, fOld: player.fOld, width: size.width, height: size.height)
        let outActors = collideWithPlayerJS.call(withArguments: [selfActorJS, playerActorJS])//.toArray()// as! [ActorJS]
        print("outActors: \(outActors)")
        
        let outSelfJS = outActors?.toArray()[0] as! ActorJS
        let outPlayerJS = outActors?.toArray()[1] as! ActorJS
        
        self.f = outSelfJS.f
        self.vel = outSelfJS.vel
        self.fOld = outSelfJS.fOld
        
        player.f = outPlayerJS.f
        player.vel = outPlayerJS.vel
        player.fOld = outPlayerJS.fOld

      }
      return .collide
    }
    return .none
  }
}

extension JSItem: CollisionHorizontal {
  public func collisionHorizontalResponse(vel: CGPoint) -> CGPoint {
    var vel = vel
    vel.x = vel.x * -1.0
    return vel
  }
}

extension JSItem: Droppable {
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
