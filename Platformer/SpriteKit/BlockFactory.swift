//
//  BlockFactory.swift
//  Platformer
//
//  Created by Richard Adem on 27/9/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import SpriteKit
import PlatformerSystem

class BlockFactory {
  static func blockNode(forTileType tileType: TileTypeFlag) -> SKNode? {
    
    if tileType.rawValue == 0 || tileType.intersection(.nonsolid).rawValue != 0  {
      return nil
    } else if tileType.intersection(.breakable).rawValue != 0 {
      
      guard tileType.intersection(.used).rawValue == 0 else {
        return nil
      }
      
      let blockNode = SKSpriteNode(imageNamed: "breakable")
      blockNode.anchorPoint = CGPoint(x: 0, y: 1)
      blockNode.yScale = -1
      blockNode.zPosition = Constants.Layer.background.rawValue
      return blockNode
    } else if tileType.intersection(.powerup).rawValue != 0 {
      
      if tileType.intersection(.used).rawValue == 0  {
        let blockNode = SKSpriteNode(imageNamed: "powerup")
        blockNode.anchorPoint = CGPoint(x: 0, y: 1)
        blockNode.yScale = -1
        blockNode.zPosition = Constants.Layer.background.rawValue
        return blockNode
      } else {
        let blockNode = SKSpriteNode(imageNamed: "empty")
        blockNode.anchorPoint = CGPoint(x: 0, y: 1)
        blockNode.yScale = -1
        blockNode.zPosition = Constants.Layer.background.rawValue
        return blockNode
      }
    } else if tileType.intersection(.slope_left).rawValue != 0 {
      // ◿
      let blockNode = SKSpriteNode(imageNamed: "slope_left")
      blockNode.anchorPoint = CGPoint(x: 0, y: 1)
      blockNode.yScale = -1
      blockNode.zPosition = Constants.Layer.background.rawValue
      return blockNode
    } else if tileType.intersection(.slope_right).rawValue != 0 {
      // ◺
      let blockNode = SKSpriteNode(imageNamed: "slope_right")
      blockNode.anchorPoint = CGPoint(x: 0, y: 1)
      blockNode.yScale = -1
      blockNode.zPosition = Constants.Layer.background.rawValue
      return blockNode
    } else if tileType.intersection(.solid).rawValue != 0 {
      // Solid comes last because blocks can be sold and breakable etc.
      let blockNode = SKSpriteNode(imageNamed: "solid")
      blockNode.anchorPoint = CGPoint(x: 0, y: 1)
      blockNode.yScale = -1
      blockNode.zPosition = Constants.Layer.background.rawValue
      return blockNode
      
    } else if tileType.intersection(.solid_on_top).rawValue != 0 {
      let blockNode = SKSpriteNode(imageNamed: "solid_on_top")
      blockNode.anchorPoint = CGPoint(x: 0, y: 1)
      blockNode.yScale = -1
      blockNode.zPosition = Constants.Layer.background.rawValue
      return blockNode
      
    } else if tileType.intersection(.pickup).rawValue != 0 {
      let blockNode = SKSpriteNode(imageNamed: "pickup")
      blockNode.anchorPoint = CGPoint(x: 0, y: 1)
      blockNode.yScale = -1
      blockNode.zPosition = Constants.Layer.background.rawValue
      blockNode.alpha = 0.25
      return blockNode
      
    } else if tileType.intersection(.player_start).rawValue != 0 {
      let blockNode = SKSpriteNode(imageNamed: "playerStart")
      blockNode.anchorPoint = CGPoint(x: 0, y: 1)
      blockNode.yScale = -1
      blockNode.zPosition = Constants.Layer.background.rawValue
      return blockNode
      
    } else if tileType.intersection(.piggy).rawValue != 0 {
      let blockNode = SKSpriteNode(imageNamed: "piggy")
      blockNode.anchorPoint = CGPoint(x: 0, y: 1)
      blockNode.yScale = -1
      blockNode.zPosition = Constants.Layer.background.rawValue
      blockNode.alpha = 0.25
      return blockNode
      
    } else if tileType.intersection(.jsItem).rawValue != 0 {
      let blockNode = SKSpriteNode(imageNamed: "item")
      blockNode.anchorPoint = CGPoint(x: 0, y: 1)
      blockNode.yScale = -1
      blockNode.zPosition = Constants.Layer.background.rawValue
      blockNode.alpha = 0.25
      return blockNode
      
    } else if tileType.intersection(.piggy).rawValue != 0 {
      let blockNode = SKSpriteNode(imageNamed: "pickAxe")
      blockNode.anchorPoint = CGPoint(x: 0, y: 1)
      blockNode.yScale = -1
      blockNode.zPosition = Constants.Layer.background.rawValue
      blockNode.alpha = 0.25
      return blockNode

    } else if tileType.intersection(.door).rawValue != 0 {
      let blockNode = SKSpriteNode(imageNamed: "door")
      blockNode.anchorPoint = CGPoint(x: 0, y: 1)
      blockNode.yScale = -1
      blockNode.zPosition = Constants.Layer.background.rawValue
      return blockNode

    } else {
      print("Unhandled block: \(tileType), \(String(tileType.rawValue, radix: 2))")
      // Unhandled blocks
      let blockNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE, height: TILESIZE))
      blockNode.fillColor = .green
      blockNode.strokeColor = .white
      blockNode.zPosition = Constants.Layer.background.rawValue
      return blockNode
    }
  }
}
