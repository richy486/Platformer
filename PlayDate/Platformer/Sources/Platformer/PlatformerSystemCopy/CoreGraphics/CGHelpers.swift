//
//  CGHelpers.swift
//
//  Created by Richard Adem on 6/21/16.
//  Copyright © 2016 Richard Adem. All rights reserved.
//

// Lerp and Clamp from Daniel Clelland https://github.com/dclelland/Lerp

//import CoreGraphics

// MARK: Lerpable protocol

// import Foundation
import PlaydateKit

public protocol Lerpable {
  func lerp(min: Self, max: Self) -> Self
  func ilerp(min: Self, max: Self) -> Self
}

// MARK: Clampable protocol

public protocol Clampable {
  func clamp(min: Self, max: Self) -> Self
}

// MARK: Vector maths protocol

public protocol Vector {
  func rotated(radians: Double) -> Self
}

// MARK: - Double
func round(_ value: Double, tollerence: Double) -> Double {
  if abs(value).truncatingRemainder(dividingBy: 1.0) < tollerence || abs(value).truncatingRemainder(dividingBy: 1.0) > 1.0 - tollerence {
    return value.rounded()//round(value)
  }
  return value
}

extension Double {
  public static let zero: Double = Double(0)
}

extension Double {
  func format(_ f: String) -> String {
//    return String(format: "%\(f)f", self)
    fatalError("Not supported in embedded mode")
  }
}

extension Double: Lerpable {
  
  /// Linear interpolation
  public func lerp(min: Double, max: Double) -> Double {
    return min + (self * (max - min))
  }
  
  /// Inverse linear interpolation
  public func ilerp(min: Double, max: Double) -> Double {
    return (self - min) / (max - min)
  }
  
}

extension Double: Clampable {
  
  /// Clamp
  public func clamp(min: Double, max: Double) -> Double {
    return Swift.min(Swift.max(self, Swift.min(min, max)), Swift.max(min, max))
  }
  
}

// MARK: - Point
extension Point {
  func distance(to: Point) -> Double {
    let dx = pow(to.x - self.x, 2)
    let dy = pow(to.y - self.y, 2)
    return sqrt(dx + dy)
  }
}

func + (left: Point, right: Point) -> Point {
  
  return Point(x: left.x + right.x, y: left.y + right.y)
}
func - (left: Point, right: Point) -> Point {
  
  return Point(x: left.x - right.x, y: left.y - right.y)
}
func * (left: Point, right: Point) -> Point {
  
  return Point(x: left.x * right.x, y: left.y * right.y)
}
func / (left: Point, right: Point) -> Point {
  
  return Point(x: left.x / right.x, y: left.y / right.y)
}

func % (left: Point, right: Point) -> Point {
  
  return Point(x: left.x.truncatingRemainder(dividingBy: right.x), y: left.y.truncatingRemainder(dividingBy: right.y))
}

func += (left: inout Point, right: Point) {
  left = left + right
}
func -= (left: inout Point, right: Point) {
  left = left - right
}
func *= (left: inout Point, right: Point) {
  left = left * right
}
func /= (left: inout Point, right: Point) {
  left = left / right
}

func * (left: Point, right: Double) -> Point {
  
  return Point(x: left.x * right, y: left.y * right)
}
func / (left: Point, right: Double) -> Point {
  
  return Point(x: left.x / right, y: left.y / right)
}
func + (left: Point, right: Double) -> Point {
  
  return Point(x: left.x + right, y: left.y + right)
}
func - (left: Point, right: Double) -> Point {
  
  return Point(x: left.x - right, y: left.y - right)
}

func floor(_ point: Point) -> Point {
  return Point(x: floor(point.x), y: floor(point.y))
}

func round(_ value: Point, tollerence: Double) -> Point {
  return Point(x: round(value.x, tollerence: tollerence),
                 y: round(value.y, tollerence: tollerence))
}

func abs(_ value: Point) -> Point {
  return Point(x: abs(value.x), y: abs(value.y))
}

extension Point {
  func format(_ f: String) -> String {
//    return String(format: "(%\(f)f, %\(f)f)", self.x, self.y)
    fatalError("Not implemented")
  }
  
  func offsetX(x: Double) -> Point {
    return Point(x: self.x + x, y: self.y)
  }
  
  func offsetY(y: Double) -> Point {
    return Point(x: self.x, y: self.y + y)
  }
}

extension Point: Lerpable {
  
  /// Linear interpolation
  public func lerp(min: Point, max: Point) -> Point {
    let x = self.x.lerp(min: min.x, max: max.x)
    let y = self.y.lerp(min: min.y, max: max.y)
    return Point(x: x, y: y)
  }
  
  /// Inverse linear interpolation
  public func ilerp(min: Point, max: Point) -> Point {
    let x = self.x.ilerp(min: min.x, max: max.x)
    let y = self.y.ilerp(min: min.y, max: max.y)
    return Point(x: x, y: y)
  }
  
}

extension Point: Clampable {
  
  /// Clamp
  public func clamp(min: Point, max: Point) -> Point {
    let x = self.x.clamp(min: min.x, max: max.x)
    let y = self.y.clamp(min: min.y, max: max.y)
    return Point(x: x, y: y)
  }
  
}

// MARK: Vector maths

extension Point: Vector {
  public func rotated(radians: Double) -> Point {
    let ca = cos(radians)
    let sa = sin(radians)
    return Point(x: ca*x - sa*y, y: sa*x - ca*y)
  }
  public var radians: Double {
    //        return atan(y/x)
    return atan2(y, x)
  }
  public var length: Double {
    return sqrt(x*x + y*y)
  }
  public var normalized: Point {
    let length = self.length
    
    guard length > 0 else {
      return Point.zero
    }
    
    return Point(x: x/length, y: y/length)
  }
}

// MARK: - Size
func + (left: Size, right: Size) -> Size {
  
  return Size(width: left.width + right.width, height: left.height + right.height)
}
func - (left: Size, right: Size) -> Size {
  
  return Size(width: left.width - right.width, height: left.height - right.height)
}
func * (left: Size, right: Size) -> Size {
  
  return Size(width: left.width * right.width, height: left.height * right.height)
}
func / (left: Size, right: Size) -> Size {
  
  return Size(width: left.width / right.width, height: left.height / right.height)
}

func * (left: Size, right: Double) -> Size {
  
  return Size(width: left.width * right, height: left.height * right)
}
func / (left: Size, right: Double) -> Size {
  
  return Size(width: left.width / right, height: left.height / right)
}

// MARK: - Size v Point
func sizeToPoint(_ size: Size) -> Point {
  return Point(x: size.width, y: size.height)
}

func * (left: Point, right: Size) -> Point {
  
  return Point(x: left.x * right.width, y: left.y * right.height)
}
func / (left: Point, right: Size) -> Point {
  
  return Point(x: left.x / right.width, y: left.y / right.height)
}
func + (left: Point, right: Size) -> Point {
  
  return Point(x: left.x + right.width, y: left.y + right.height)
}
func - (left: Point, right: Size) -> Point {
  
  return Point(x: left.x - right.width, y: left.y - right.height)
}

extension Size: Lerpable {
  
  /// Linear interpolation
  public func lerp(min: Size, max: Size) -> Size {
    let width = self.width.lerp(min: min.width, max: max.width)
    let height = self.height.lerp(min: min.height, max: max.height)
    return Size(width: width, height: height)
  }
  
  /// Inverse linear interpolation
  public func ilerp(min: Size, max: Size) -> Size {
    let width = self.width.ilerp(min: min.width, max: max.width)
    let height = self.height.ilerp(min: min.height, max: max.height)
    return Size(width: width, height: height)
  }
  
}

extension Size: Clampable {
  
  /// Clamp
  public func clamp(min: Size, max: Size) -> Size {
    let width = self.width.clamp(min: min.width, max: max.width)
    let height = self.height.clamp(min: min.height, max: max.height)
    return Size(width: width, height: height)
  }
  
}
