//
//  GravityComponent.swift
//  Platformer
//
//  Created by Richard Adem on 1/12/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

protocol GravityComponent {
  func updateGravityComponent(currentTime: TimeInterval, level: Level) -> Level
}

extension GravityComponent where Self: UsesComponents, Self: Actor {
  func updateGravityComponent(currentTime: TimeInterval, level: Level) -> Level {
    // Lets add gravity here
    if inAir {
      vel.y = cap(fallingVelocity: vel.y + AppState.shared.GRAVITATION)
    }
    
    return level
  }
}
