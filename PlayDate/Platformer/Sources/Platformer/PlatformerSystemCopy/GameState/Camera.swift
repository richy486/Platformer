//
//  Camera.swift
//  Platformer
//
//  Created by Richard Adem on 21/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

//import CoreGraphics
//import UIKit
// import Foundation


public enum CameraMode {
  case center
  case lockLeftOfPlayer
  case lockRightOfPlayer
}

public final class Camera {
  public var position = Point.zero
  private(set) var target = Point.zero
  private var cameraMode = CameraMode.center
  private var lastUpdateTimeInterval: TimeInterval = 0
  
  func update<C: CollisionObject>(currentTime: TimeInterval, targetObject: C) {
    print(" Camera update")
    if lastUpdateTimeInterval == 0 {
      lastUpdateTimeInterval = currentTime
    }
    let delta = currentTime - lastUpdateTimeInterval
    
    guard AppState.shared.cameraTracking else {
      return
    }
    
    // Camera X
    
    // Update to the correct mode
    switch cameraMode {
    case .center:
      
      if targetObject.f.x - position.x > Double(3*TILESIZE) {
//        print("switch to lock left of targetObject")
        cameraMode = .lockLeftOfPlayer
      } else if targetObject.f.x - position.x < -Double(3*TILESIZE) {
//        print("switch to lock right of targetObject")
        cameraMode = .lockRightOfPlayer
      }
    case .lockLeftOfPlayer:
      // direction right -> center
      if targetObject.vel.x < 0.0 {
        cameraMode = .center
      }
    case .lockRightOfPlayer:
      if targetObject.vel.x > 0.0 {
        cameraMode = .center
      }
    }
    
    // Update the camera depending on the mode
    
    switch cameraMode {
    case .center:
      break
    case .lockLeftOfPlayer:
      target.x = targetObject.f.x + Double(targetObject.size.width)/2 + Double(TILESIZE)
    case .lockRightOfPlayer:
      target.x = targetObject.f.x + Double(targetObject.size.width)/2 - Double(TILESIZE)
    }
    
    if cameraMode == .lockLeftOfPlayer || cameraMode == .lockRightOfPlayer {
      
      let distance = abs(position.x - target.x)
      let percent = distance == 0 ? 0 : (AppState.shared.cameraMoveSpeed / distance) * Double(delta)
      let posX = percent
        .clamp(min: 0, max: 1)
        .lerp(min: position.x, max: target.x)
      position.x = posX
      
    }
    print(" Camera w x position: \(position)")

    // Camera Y
    if targetObject.lastGroundPosition >= 0 && targetObject.lastGroundPosition < AppState.shared.blocks.count {
      target.y = Double((targetObject.lastGroundPosition + AppState.shared.BLOCKSOFFCENTER) * TILESIZE)
      let distance = abs(position.y - target.y)
      print(" Camera distance: \(Int(distance))")
      let percent = distance == 0 ? 0 : (AppState.shared.cameraMoveSpeed / distance) * Double(delta)
      let posY = percent
        .clamp(min: 0, max: 1)
        .lerp(min: position.y, max: target.y)
      print(" Camera posY: \(Int(posY))")
      position.y = posY
    }
    print(" Camera w y position: \(position)")

    lastUpdateTimeInterval = currentTime
    print(" Camera update end")
  }
}
