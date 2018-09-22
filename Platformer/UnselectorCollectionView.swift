//
//  UnselectorCollectionView.swift
//  Platformer
//
//  Created by Richard Adem on 22/9/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import AppKit
import SpriteKit

class UnselectorCollectionView: NSCollectionView {
    
    weak var gameScene: SKScene!
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        print("hit test")
        
        window?.makeFirstResponder(gameScene.view)
        
        return super.hitTest(point)
        
    }
}
