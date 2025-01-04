//
//  Vector.swift
//  PlatformerSystem
//
//  Created by Richard Adem on 29/12/2024.
//
import Foundation

public struct Point {
  public var x: Double
  public var y: Double
}


extension Point {
  public static let zero: Point = .init(x: 0, y: 0)
  public init(x: Int, y: Int) {
    self.init(x: Double(x), y: Double(y))
  }
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
