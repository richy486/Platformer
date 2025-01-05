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

extension Point {
  var playDatePoint: PlaydateKit.Point {
    PlaydateKit.Point(x: Float(x), y: Float(y))
  }
}

// MARK: - Game

final class Game: PlaydateGame {
  private(set) var gameManager = GameManager()
  let background: Background
  private var lastCurrentTimeMilliseconds: CUnsignedInt = 0
  private var spriteNodes: [UUID: GameSprite] = [:]
  private let table: Graphics.BitmapTable

  // MARK: Lifecycle

  init() {
    let table: Graphics.BitmapTable
    do {
      // 5 x 3 * 16px x 16px
      table = try Graphics.BitmapTable(path: "blocks")
    } catch {
      print("Fatal Error loading bitmap: \(error)")
      fatalError()
    }
    self.table = table

    // AppState.load()
    gameManager.loadLevel()

    background = Background(table: table, allBlocks: gameManager.allBlocks())

    background.addToDisplayList()
  }

  // MARK: Internal

//  let logo = Logo()

  func update() -> Bool {

    // Before update
    if lastCurrentTimeMilliseconds == 0 {
      lastCurrentTimeMilliseconds = System.currentTimeMilliseconds
    }
    let timeIntervalMilliseconds = System.currentTimeMilliseconds - lastCurrentTimeMilliseconds

    // Keys

    // Update Game System
    let controls = Controls(player: ControlCommands(left: false,
                                                    right: false,
                                                    jump: false,
                                                    turbo: false))

    let seconds: Double = Double(timeIntervalMilliseconds) / 1000
    gameManager.update(currentTime: seconds, controls: controls)

    // After update
    let allActorsAndKeys = gameManager.allActors()

    // Remove old actors
    let removedUUIDs = Set(spriteNodes.keys).subtracting(Set(allActorsAndKeys.keys))
    for removedUUID in removedUUIDs {
      guard let removedNode = spriteNodes.removeValue(forKey: removedUUID) else {
        continue
      }
      removedNode.removeFromDisplayList()
    }

//    var player: Player?

    for (uuid, actor) in allActorsAndKeys {

      // Create new actors
      if spriteNodes[uuid] == nil {
        guard let node = GameSprite(table: table, actor: actor) else {
          continue
        }
        spriteNodes[uuid] = node
//        addChild(node)
        node.addToDisplayList()
      }

      // Update actors
      guard let node = spriteNodes[uuid] else {
        print("Couldn't update node for UUID: \(uuid)")
        continue
      }
      node.position = actor.f.playDatePoint

//      if let playerActor = actor as? Player {
//        player = playerActor
//      }

      // TODO:
//      if let spriteNode = node as? SKSpriteNode {
//        if actor.direction.contains(.right) {
//          spriteNode.anchorPoint.x = 0
//          spriteNode.xScale = 1
//        } else {
//          spriteNode.anchorPoint.x = 1
//          spriteNode.xScale = -1
//        }
//      }
    }

    // Update Playdate system
    Sprite.updateAndDrawDisplayListSprites()
    System.drawFPS()

    lastCurrentTimeMilliseconds = System.currentTimeMilliseconds
    return true
  }
  
  func gameWillPause() {
    print("Paused!")
  }
}

