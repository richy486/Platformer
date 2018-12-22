//
//  Camera.swift
//  Platformer
//
//  Created by Richard Adem on 21/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

public enum CameraMode {
    case center
    case lockLeftOfPlayer
    case lockRightOfPlayer
}

public class Camera {
    public var position = CGPoint.zero
    private(set) var target = CGPoint.zero
    private var cameraMode = CameraMode.center
    private var lastUpdateTimeInterval: CFTimeInterval = 0
    
    func update(currentTime: TimeInterval, targetObject: CollisionObject) {
        if lastUpdateTimeInterval == 0 {
            lastUpdateTimeInterval = currentTime
        }
        let delta = currentTime - lastUpdateTimeInterval
        
        guard AppState.shared.cameraTracking else {
            return
        }
        
        // Camera X
        
        // Update to the corrent mode
        switch cameraMode {
        case .center:
            
            if targetObject.f.x - position.x > CGFloat(3*TILESIZE) {
                print("switch to lock left of targetObject")
                cameraMode = .lockLeftOfPlayer
            } else if targetObject.f.x - position.x < -CGFloat(3*TILESIZE) {
                print("switch to lock right of targetObject")
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
            target.x = targetObject.f.x + CGFloat(targetObject.size.width)/2 + CGFloat(TILESIZE)
        case .lockRightOfPlayer:
            target.x = targetObject.f.x + CGFloat(targetObject.size.width)/2 - CGFloat(TILESIZE)
        }
        
        if cameraMode == .lockLeftOfPlayer || cameraMode == .lockRightOfPlayer {
            
            let distance = abs(position.x - target.x)
            let percent = (AppState.shared.cameraMoveSpeed / distance) * CGFloat(delta)
            let posX = percent
                .clamp(min: 0, max: 1)
                .lerp(min: position.x, max: target.x)
            position.x = posX
            
        }
        
        // Camera Y
        if targetObject.lastGroundPosition >= 0 && targetObject.lastGroundPosition < AppState.shared.blocks.count {
            target.y = CGFloat((targetObject.lastGroundPosition + AppState.shared.BLOCKSOFFCENTER) * TILESIZE)
            let distance = abs(position.y - target.y)
            let percent = (AppState.shared.cameraMoveSpeed / distance) * CGFloat(delta)
            let posY = percent
                .clamp(min: 0, max: 1)
                .lerp(min: position.y, max: target.y)
            position.y = posY
        }
        
        lastUpdateTimeInterval = currentTime
    }
}
