//
//  Vector.swift
//  PlatformerSystem
//
//  Created by Richard Adem on 29/12/2024.
//

public struct Point {
  public var x: Double
  public var y: Double

  public init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }
}

extension Point {
  public static var zero: Point { Point(x: 0, y: 0) }
  public init(x: Int, y: Int) {
    self.init(x: Double(x), y: Double(y))
  }
}

extension Point: CustomStringConvertible {
  public var description: String {
    doubleFormat(double: x) + ", " + doubleFormat(double: y)
  }
}

func doubleFormat(double: Double) -> String {
    let int = Int(double)
    let frac = Int((double - Double(int)) * 100)
    return "\(int).\(frac)"
}

public struct Size {
  public var width: Double
  public var height: Double
  public init(width: Double, height: Double) {
    self.width = width
    self.height = height
  }
  public init(width: Int, height: Int) {
    self.init(width: Double(width), height: Double(height))
  }
}
