import PlaydateKit

extension Graphics.BitmapTable {

}

let X = -1
let SuperPosition = -2
let None = -3

final class Background: Sprite.Sprite {

  let table: Graphics.BitmapTable
  var map: [[Int]]

  init( table: Graphics.BitmapTable, allBlocks: [[Int]]) {
    map = allBlocks
    self.table = table
    super.init()

    bounds = Rect(
      x: 0,
      y: 0,
      width: Display.width,
      height: Display.height
    )
  }

  override func update() {
    markDirty()
  }

  override func draw(bounds: Rect, drawRect: Rect) {
    Graphics.fillRect(bounds, color: .white)
    Graphics.drawRect(bounds)

    for y in 0..<map.count {
      for x in 0..<map[y].count {
        let tileType = map[y][x]
        let tile: Int

        switch tileType {
          case S: tile = 0
          case T: tile = 1
          case B: tile = 2
          case P: tile = 11
          default: tile = None
        }

        if let bitmap = table.bitmap(at: tile) {
          Graphics.drawBitmap(bitmap, at: PlaydateKit.Point(x: Float(Double(x) * GlobalConstants.tileSize.width),
                                                            y: Float(Double(y) * GlobalConstants.tileSize.height)))
        }

      }
    }

  }
}
