//
//  UsesComponents.swift
//  Platformer
//
//  Created by Richard Adem on 1/12/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

protocol UsesComponents {
  func updateComponents(currentTime: TimeInterval, level: Level) -> Level
}

extension UsesComponents where Self: Actor {
  func updateComponents(currentTime: TimeInterval, level: Level) -> Level {
    return level
  }
}
