//
//  Direction.swift
//  Platformer
//
//  Created by Richard Adem on 11/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

//import CoreGraphics
// import Foundation

public struct Direction: OptionSet {
  
  public let rawValue: Int
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  public static var stationary: Direction { Direction(rawValue: 0) }
  public static var up: Direction { Direction(rawValue: 1 << 0) }
  public static var down: Direction { Direction(rawValue: 1 << 1) }
  public static var left: Direction { Direction(rawValue: 1 << 2) }
  public static var right: Direction { Direction(rawValue: 1 << 3) }
  public static var upLeft: Direction { Direction(arrayLiteral: [.up, .left]) }
  public static var upRight: Direction { Direction(arrayLiteral: [.up, .right]) }
  public static var downLeft: Direction { Direction(arrayLiteral: [.down, .left]) }
  public static var downRight: Direction { Direction(arrayLiteral: [.down, .right]) }

  public var radians: Double {
    
    var radians = Double.zero
    
    // Start from up or down
    if self.contains(.up) {
      radians = Double.pi * 1.5
      
      if self.contains(.left) {
        radians -= Double.pi / 4
      } else if self.contains(.right) {
        radians += Double.pi / 4
      }
      
    } else if self.contains(.down) {
      
      radians = Double.pi / 2
      if self.contains(.left) {
        radians += Double.pi / 4
      } else if self.contains(.right) {
        radians -= Double.pi / 4
      }
    }
    
    //        // Add left or right
    //        if self.contains(.left) {
    //            radians -= Double.pi / 4
    //        } else if self.contains(.right) {
    //            radians += Double.pi / 4
    //        }
    
    return radians
  }
  
  public var string: String {
    guard self != .stationary else {
      return "Stationary"
    }
    
    var str = ""
    if self.contains(.up) {
      str.append("Up")
    } else if self.contains(.down) {
      str.append("Down")
    }
    
    if self.contains(.left) {
      str.append(", Left")
    } else if self.contains(.right) {
      str.append(", Right")
    }
    
    return str
  }
}
