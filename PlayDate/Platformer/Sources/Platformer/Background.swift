import PlaydateKit

extension Graphics.BitmapTable {

}

let X = -1
let SuperPosition = -2
let None = -3

final class Background: Sprite.Sprite {

  private static let height: Int = 16
  let table: Graphics.BitmapTable


  var map: [[Int]]


  init(allBlocks: [[Int]]) {
    map = allBlocks
    do {
      // 5 x 3 * 16px x 16px
      table = try Graphics.BitmapTable(path: "blocks")
    } catch {
      print("Fatal Error loading bitmap: \(error)")
      fatalError()
    }
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

//    print("draw rect: \(Int(drawRect.x)) \(Int(drawRect.y)) \(Int(drawRect.width)) \(Int(drawRect.height))")

    for y in 0..<map.count {
      for x in 0..<map[y].count {
        let tileType = map[y][x]
        let tile: Int

        switch tileType {
          case S: tile = 0
          case T: tile = 1
          case B: tile = 2
          default: tile = None
        }

        if let bitmap = table.bitmap(at: tile) {
          Graphics.drawBitmap(bitmap, at: PlaydateKit.Point(x: x * Self.height, y: y * Self.height))
        }

      }
    }

  }
}
