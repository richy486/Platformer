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

  override func draw(bounds: Rect, drawRect: Rect) {
    if let bitmap = table.bitmap(at: tile) {
      Graphics.drawBitmap(bitmap, at: self.position)

    }
  }
}
