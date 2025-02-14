//
//  GameSprite.swift
//  Platformer
//
//  Created by Richard Adem on 06/01/2025.
//

import PlaydateKit

class GameSprite: Sprite.Sprite {
  let table: Graphics.BitmapTable
  let tile: Int

  init?(table: Graphics.BitmapTable, actor: Actor) {
    self.table = table

    switch actor {
      case is Player: tile = 12
      case is Pickup: tile = 9
      case is Piggy: tile = 10
      case is PickAxe: tile = 8
//      case is JSItem: tile = 7
      default: return nil
    }
    super.init()


    bounds = Rect(
      x: 0,
      y: 0,
      width: Float(GlobalConstants.tileSize.width),
      height: Float(GlobalConstants.tileSize.height)
    )
  }

//  override func update() {
//    markDirty()
//  }

  override func draw(bounds: Rect, drawRect: Rect) {
//    Graphics.fillRect(bounds, color: .white)
//    Graphics.drawRect(bounds)

    if let bitmap = table.bitmap(at: tile) {
      let at = PlaydateKit.Point(x: position.x - Float(GlobalConstants.tileSize.width)/2,
                                 y: position.y - Float(GlobalConstants.tileSize.height)/2)
      Graphics.drawBitmap(bitmap, at: at)
//      Graphics.fillRect(bounds)
//      print("player \(Int(self.position.x)) \(Int(self.position.y))")
    }
  }
}
