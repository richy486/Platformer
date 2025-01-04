//
//  Logo.swift
//  Platformer
//
//  Created by Richard Adem on 04/01/2025.
//

import PlaydateKit

class Logo: Sprite.Sprite {
  // MARK: Lifecycle

  override init() {
    super.init()
    //        image = try! Graphics.Bitmap(path: "logo.png")
    bounds = .init(x: 0, y: 0, width: 400, height: 240)
  }

  // MARK: Internal

  override func update() {
    moveBy(dx: 0, dy: sinf(System.elapsedTime * 4))
  }
}
