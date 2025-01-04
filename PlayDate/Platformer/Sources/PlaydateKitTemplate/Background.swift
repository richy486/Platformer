import PlaydateKit

extension Graphics.BitmapTable {

}

let X = -1
let SuperPosition = -2
let None = -3

final class Background: Sprite.Sprite {

  private static let height: Int = 16
  let table: Graphics.BitmapTable

  // screen: 25 x 15


//  let map: [[Int]] = [
//    [3, 11, 11, 11, 11,  4,  3, 11,  4],
//    [7,  X,  X,  X,  X,  5,  7,  X,  5],
//    [7,  X,  X,  X,  X, 10, 12,  X,  5],
//    [7,  X,  X,  X,  X,  X,  X,  X,  5],
//    [8,  1,  2,  X,  X,  X,  0,  1,  9],
//    [3, 11, 12,  X,  X,  X, 10, 11,  4],
//    [7,  X,  X,  X,  X,  X,  X,  X,  5],
//    [7,  X,  X,  X,  X,  X,  X,  X,  5],
//    [7,  X,  X,  X,  X,  X,  X,  X,  5],
//    [7,  X,  X,  X,  X,  X,  X,  X,  5],
//    [7,  X,  X,  X,  X,  X,  X,  X,  5],
//    [8,  1,  1,  1,  1,  9,  8,  1,  9],
//
//  ]

  var map: [[Int]]

//  var gameplayMap: [[[Int]]] {
//    let allTiles: [Int] = (0...14).map { $0 }
//    return Array(repeating: Array(repeating: allTiles, count: 25), count: 15)
//  }

//  func xy(from index: Int) -> (Int, Int) {
//    return (index / map[0].count, index % map[0].count)
//  }

  struct Neighbours: CustomStringConvertible {
    var top: [Int] = []
    var left: [Int] = []
    var bottom: [Int] = []
    var right: [Int] = []

    var description: String {
//      "top: \(top.count), left: \(left.count), bottom: \(bottom.count), right: \(right.count)"
      let topValues = Set<Int>(top).map{ "\($0)" }.joined(separator: ", ")
      let leftValues = Set<Int>(left).map{ "\($0)" }.joined(separator: ", ")
      let bottomValues = Set<Int>(bottom).map{ "\($0)" }.joined(separator: ", ")
      let rightValues = Set<Int>(right).map{ "\($0)" }.joined(separator: ", ")
      return "top: \(topValues), left: \(leftValues), bottom: \(bottomValues), right: \(rightValues)"
    }
  }

  init(allBlocks: [[Int]]) {
    map = allBlocks
    do {
      // 5 x 3 * 16px x 16px
      table = try Graphics.BitmapTable(path: "tiles")
    } catch {
      print("Error loading bitmap: \(error)")
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

    print("draw rect: \(Int(drawRect.x)) \(Int(drawRect.y)) \(Int(drawRect.width)) \(Int(drawRect.height))")

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

//        let tile: Int
//        if tiles.count == 1 {
//          tile = tiles[0]
//
//        } else if tiles.count > 1 {
//          let index = Int.random(in: 0..<tiles.count)
//          tile = tiles[index]
//        } else {
//          tile = None
//        }
        if let bitmap = table.bitmap(at: tile) {
          Graphics.drawBitmap(bitmap, at: PlaydateKit.Point(x: x * Self.height, y: y * Self.height))
        }

      }
    }

  }
}
