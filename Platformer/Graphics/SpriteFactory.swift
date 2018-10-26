//
//  SpriteFactory.swift
//  Platformer
//
//  Created by Richard Adem on 23/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import SpriteKit

class SpriteFactory {
    static func spriteNode(forCollisionObject collisionObject: CollisionObject) -> SKNode? {
        if collisionObject is Player {
            let playerNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: PW, height: PH))
            playerNode.fillColor = .red
            playerNode.name = "player"
            playerNode.zPosition = Constants.Layer.active.rawValue
            
            let playerNodeLeft = SKShapeNode(rect: CGRect(x: 0, y: 0, width: PW/2, height: PH))
            playerNodeLeft.fillColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
            playerNodeLeft.position = CGPoint(x: 0, y: 0)
            playerNodeLeft.name = "playerLeft"
            playerNodeLeft.zPosition = Constants.Layer.active.rawValue
            playerNode.addChild(playerNodeLeft)
            
            let playerNodeRight = SKShapeNode(rect: CGRect(x: 0, y: 0, width: PW/2, height: PH))
            playerNodeRight.fillColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            playerNodeRight.position = CGPoint(x: PW/2, y: 0)
            playerNodeRight.name = "playerRight"
            playerNodeRight.zPosition = Constants.Layer.active.rawValue
            playerNode.addChild(playerNodeRight)
            
            return playerNode
        }
        return nil
    }
}
