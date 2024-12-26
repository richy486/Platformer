//
//  UsesComponents.swift
//  Platformer
//
//  Created by Richard Adem on 1/12/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation
import CoreGraphics
//import UIKit
import Foundation


protocol UsesComponents {
  func updateComponents(currentTime: TimeInterval, level: Level) -> Level
}

extension UsesComponents where Self: Actor {
  func updateComponents(currentTime: TimeInterval, level: Level) -> Level {
    var level = level
    
    if let gravityAffected = self as? GravityComponent {
      level = gravityAffected.updateGravityComponent(currentTime: currentTime, level: level)
    }
    
    return level
    
  }
}
