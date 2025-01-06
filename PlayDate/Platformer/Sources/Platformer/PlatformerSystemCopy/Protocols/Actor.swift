//
//  Actor.swift
//  Platformer
//
//  Created by Richard Adem on 1/12/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

//// import Foundation
//import CoreGraphics
//import UIKit
// import Foundation


//public typealias Actor = Collision & CollisionObject & CollisionHorizontal

public class Actor: Collision, CollisionObject, CollisionHorizontal, ActorCarrier {
  public init () {}

  public func tryCollide(withObject object: Actor) -> CollideResult {
    return .none

  }
  public func collisionHorizontalResponse(vel: Point) -> Point {
    return .zero
  }

  public var f: Point = .zero
  public var i: IntPoint = .zero
//  public var _f: Point = .zero
//  public var _i: IntPoint = .zero
  public var fOld: Point = .zero
  public var vel: Point = .zero
  public var inAir: Bool = false
  public var lastSlopeTilePoint: IntPoint?  = nil
  public var slopesBelow: (left: TileTypeFlag?, right: TileTypeFlag?) = (nil, nil)
  public var lastGroundPosition: Int = .max
  public var size: IntSize = .zero
  public var direction: Direction = []
  public var actors: [UUID: Actor] = [:]

  public func update(currentTime: TimeInterval, level: Level) -> Level {
    return level
  }

  public func drop(by actor: Actor) {

  }
}
