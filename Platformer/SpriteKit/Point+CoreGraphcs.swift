//
//  Point+CoreGraphcs.swift
//  Platformer
//
//  Created by Richard Adem on 05/01/2025.
//  Copyright © 2025 Richard Adem. All rights reserved.
//

import PlatformerSystem
import CoreGraphics

extension Point {
  var cgPoint: CGPoint {
    CGPoint(x: x, y: y)
  }
//  init(cgPoint: CGPoint) {
//    self.init(x: Double(cgPoint.x), y: Double(cgPoint.y))
//  }
}
