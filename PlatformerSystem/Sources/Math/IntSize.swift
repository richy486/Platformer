//
//  IntSize.swift
//  Platformer
//
//  Created by Richard Adem on 2/11/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

public struct IntSize: Hashable {
  public var width: Int
  public var height: Int
  public init() {
    width = 0
    height = 0
  }
  public init(width: Int, height: Int) {
    self.width = width
    self.height = height
  }
  public static var zero: IntSize {
    get {
      return IntSize()
    }
  }
  
  var cgSize: Size {
    return Size(width: Double(width), height: Double(height))
  }
}

extension Size {
  var intSize: IntSize {
    return IntSize(width: Int(width), height: Int(height))
  }
}
