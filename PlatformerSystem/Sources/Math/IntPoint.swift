//
//  IntPoint.swift
//  Platformer
//
//  Created by Richard Adem on 2/11/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

public struct IntPoint: Hashable {
  public var x: Int
  public var y: Int
  public init() {
    x = 0
    y = 0
  }
  public init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }
  public static var zero: IntPoint {
    get {
      return IntPoint()
    }
  }
  
  var cgPoint: Point {
    return Point(x: Double(x), y: Double(y))
  }
}

extension Point {
  var intPoint: IntPoint {
    return IntPoint(x: Int(x), y: Int(y))
  }
}

func / (left: IntPoint, right: IntPoint) -> IntPoint {
  IntPoint(x: left.x / right.x, y: left.y / right.y)
}
func / (left: IntPoint, right: Int) -> IntPoint {
  IntPoint(x: left.x / right, y: left.y / right)
}
