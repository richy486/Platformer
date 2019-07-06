//
//  CollisionHorizontal.swift
//  Platformer
//
//  Created by Richard Adem on 14/11/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import CoreGraphics

public protocol CollisionHorizontal {
  func collisionHorizontalResponse(vel: CGPoint) -> CGPoint
}
