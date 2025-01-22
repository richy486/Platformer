//
//  ControlCommands.swift
//  Platformer
//
//  Created by Richard Adem on 21/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

// import Foundation

public struct ControlCommands {
  public let left: Bool
  public let right: Bool
  public let jump: Bool
  public let turbo: Bool
  
  public init(left: Bool,
              right: Bool,
              jump: Bool,
              turbo: Bool) {
    
    self.left = left
    self.right = right
    self.jump = jump
    self.turbo = turbo
    
  }
  
}
