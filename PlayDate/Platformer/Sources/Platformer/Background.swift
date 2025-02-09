import PlaydateKit

extension Graphics.BitmapTable {

}

let X = -1
let SuperPosition = -2
let None = -3

final class Background: Sprite.Sprite {

  let table: Graphics.BitmapTable
  var map: [[Int]]

  init(table: Graphics.BitmapTable, allBlocks: [[Int]]) {
    map = allBlocks
    self.table = table
    super.init()

    
    let height = map.count
    if height > 0 {
      let width = map[0].count
      bounds = Rect(
        x: 0,
        y: 0,
        width: width * Int(GlobalConstants.tileSize.width),
        height: height * Int(GlobalConstants.tileSize.height)
      )
    }
  }

  override func draw(bounds: Rect, drawRect: Rect) {
    Graphics.fillRect(bounds, color: .white)
    Graphics.drawRect(bounds)

    for y in 0..<map.count {
      for x in 0..<map[y].count {
        let tileType = map[y][x]
        let tile: Int

        if tileType & TileTypeFlag.solid_on_top.rawValue == TileTypeFlag.solid_on_top.rawValue {
          tile = 1
        } else if tileType & TileTypeFlag.breakable.rawValue == TileTypeFlag.breakable.rawValue {
          if tileType & TileTypeFlag.used.rawValue == TileTypeFlag.used.rawValue {
            tile = None
          } else {
            tile = 2
          }
        } else if tileType & TileTypeFlag.powerup.rawValue == TileTypeFlag.powerup.rawValue {
          if tileType & TileTypeFlag.used.rawValue == TileTypeFlag.used.rawValue {
            tile = 3
          } else {
            tile = 4
          }
        } else if tileType & TileTypeFlag.player_start.rawValue == TileTypeFlag.player_start.rawValue {
          tile = 11
        } else if tileType & TileTypeFlag.slope_left.rawValue == TileTypeFlag.slope_left.rawValue {
          tile = 5
        } else if tileType & TileTypeFlag.slope_right.rawValue == TileTypeFlag.slope_right.rawValue {
          tile = 6
        } else if tileType & TileTypeFlag.solid.rawValue == TileTypeFlag.solid.rawValue {
          // Regular solid, not or-ed with anything else.
          tile = 0
        } else {
          tile = None
        }

        if let bitmap = table.bitmap(at: tile) {
          Graphics.drawBitmap(bitmap, at: PlaydateKit.Point(x: Float(Double(x) * GlobalConstants.tileSize.width),
                                                            y: Float(Double(y) * GlobalConstants.tileSize.height)))
        }

      }
    }

  }

  func mapChange(point: IntPoint, tileType: TileTypeFlag) {
    guard point.y < map.count && point.y >= 0  else {
      return
    }
    guard point.x < map[point.y].count && point.x >= 0  else {
      return
    }
    map[point.y][point.x] = tileType.rawValue
    markDirty()
  }
}
