//
//  TileItem.swift
//  Platformer
//
//  Created by Richard Adem on 21/9/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Cocoa

extension NSUserInterfaceItemIdentifier {
    static let tileItem = NSUserInterfaceItemIdentifier("tileItem")
}

class TileItem: NSCollectionViewItem {

    @IBOutlet weak var selectedImageView: NSImageView!
    @IBOutlet weak var tileImageView: NSImageView!
    @IBOutlet weak var tileLabel: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func setup(withTileType tileType: TileTypeFlag) {
        switch tileType {
        case .nonsolid:
            tileLabel.isHidden = false
            tileLabel.stringValue = "🗑"
            tileImageView.isHidden = true
        case [.breakable, .solid]:
            tileLabel.isHidden = true
            tileImageView.image = #imageLiteral(resourceName: "breakable")
            tileImageView.isHidden = false
        case [.powerup, .solid]:
            tileLabel.isHidden = true
            tileImageView.image = #imageLiteral(resourceName: "powerup")
            tileImageView.isHidden = false
        case .solid:
            tileLabel.isHidden = true
            tileImageView.image = #imageLiteral(resourceName: "solid")
            tileImageView.isHidden = false
        case .solid_on_top:
            tileLabel.isHidden = true
            tileImageView.image = #imageLiteral(resourceName: "solid_on_top")
            tileImageView.isHidden = false
        case .slope_left: // left ◿
            tileLabel.isHidden = true
            tileImageView.image = #imageLiteral(resourceName: "slope_left")
            tileImageView.isHidden = false
        case .slope_right: // right ◺
            tileLabel.isHidden = true
            tileImageView.image = #imageLiteral(resourceName: "slope_right")
            tileImageView.isHidden = false
        default:
            break
        }
    }
    
    override var isSelected: Bool {
        didSet {
            // Can't use layers here because layer is nil on view did layout and first cell creation
            selectedImageView.isHidden = !isSelected
            
        }
    }
    
}
