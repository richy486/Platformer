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
            let playerNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: collisionObject.size.width, height: collisionObject.size.height))
            playerNode.fillColor = .red
            playerNode.name = "player"
            playerNode.zPosition = Constants.Layer.active.rawValue
            
//            let playerNodeLeft = SKShapeNode(rect: CGRect(x: 0, y: 0, width: collisionObject.size.width/2, height: collisionObject.size.height))
//            playerNodeLeft.fillColor = #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1)
//            playerNodeLeft.position = CGPoint(x: 0, y: 0)
//            playerNodeLeft.name = "playerLeft"
//            playerNodeLeft.zPosition = Constants.Layer.active.rawValue
//            playerNode.addChild(playerNodeLeft)
//
//            let playerNodeRight = SKShapeNode(rect: CGRect(x: 0, y: 0, width: collisionObject.size.width/2, height: collisionObject.size.height))
//            playerNodeRight.fillColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
//            playerNodeRight.position = CGPoint(x: collisionObject.size.width/2, y: 0)
//            playerNodeRight.name = "playerRight"
//            playerNodeRight.zPosition = Constants.Layer.active.rawValue
//            playerNode.addChild(playerNodeRight)
            
//            let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE, height: TILESIZE))
//            node.fillColor = .clear
//            node.strokeColor = .white
//            node.position = CGPoint(x: 0, y: 0)
//            node.zPosition = Constants.Layer.debug.rawValue
//            playerNode.addChild(node)
            
            return playerNode
        }
        
        if collisionObject is Pickup {
            let blockNode = SKSpriteNode(imageNamed: "pickup")
            blockNode.anchorPoint = CGPoint(x: 0, y: 1)
            blockNode.yScale = -1
            blockNode.zPosition = Constants.Layer.active.rawValue
            
//            let node = SKShapeNode(rect: CGRect(x: 0,
//                                                y: 0,
//                                                width: collisionObject.size.width,
//                                                height: collisionObject.size.height))
//            node.fillColor = .clear
//            node.strokeColor = .white
//            node.position = CGPoint(x: 0, y: 0)
//            node.yScale = -1
//            node.zPosition = Constants.Layer.debug.rawValue
//            blockNode.addChild(node)
            
            return blockNode
        }
        
        if collisionObject is Piggy {
            let blockNode = SKSpriteNode(imageNamed: "piggy")
            blockNode.anchorPoint = CGPoint(x: 0, y: 1)
            blockNode.yScale = -1
            blockNode.zPosition = Constants.Layer.active.rawValue
            
            return blockNode
        }
        return nil
    }
}
