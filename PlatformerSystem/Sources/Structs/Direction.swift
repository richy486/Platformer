//
//  Direction.swift
//  Platformer
//
//  Created by Richard Adem on 11/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

//import CoreGraphics
import Foundation

public struct Direction: OptionSet {
  
  public let rawValue: Int
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  public static let stationary = Direction(rawValue: 0)
  public static let up = Direction(rawValue: 1 << 0)
  public static let down = Direction(rawValue: 1 << 1)
  public static let left = Direction(rawValue: 1 << 2)
  public static let right = Direction(rawValue: 1 << 3)
  public static let upLeft = Direction(arrayLiteral: [.up, .left])
  public static let upRight = Direction(arrayLiteral: [.up, .right])
  public static let downLeft = Direction(arrayLiteral: [.down, .left])
  public static let downRight = Direction(arrayLiteral: [.down, .right])
  
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
