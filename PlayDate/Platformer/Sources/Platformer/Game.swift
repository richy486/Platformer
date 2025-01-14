import PlaydateKit


// MARK: - Game

final class Game: PlaydateGame {
  private(set) var gameManager = GameManager()
  let background: Background
  private var lastCurrentTimeMilliseconds: CUnsignedInt = 0
  private var spriteNodes: [UUID: GameSprite] = [:]
  private let table: Graphics.BitmapTable
  private var cameraStart: IntPoint = IntPoint(x: -9999, y: -9999)

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

    gameManager.observer.doUpdate(from: self) { package, aSelf in
      print(package.message)
      switch package.message {
        case Constants.kNotificationMapChange:
          guard let point = package.point else {
            break
          }
          guard let tileType = package.tileType else {
            break
          }
          let str = String(tileType.rawValue, radix: 2)
          print("map change: tile type \(str)")
          aSelf.background.mapChange(point: point, tileType: tileType)
        default: break
      }
    }
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
    let controls = Controls(player: ControlCommands(left: System.buttonState.current.contains(.left),
                                                    right: System.buttonState.current.contains(.right),
                                                    jump: System.buttonState.current.contains(.a),
                                                    turbo: System.buttonState.current.contains(.b)))

    let seconds: Double = Double(timeIntervalMilliseconds) / 1000
//    print("Milliseconds: \(timeIntervalMilliseconds)")
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

    var player: Player?

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
      node.position = PlaydateKit.Point(x: Float(actor.f.x)/2, y: Float(actor.f.y)/2) //actor.f.playDatePoint

      if let playerActor = actor as? Player {
        player = playerActor
      }

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

    // Camera
    print("-- update camera --")
    let cameraPositionPoint = gameManager.cameraPosition()
    print("got point \(cameraPositionPoint.description)")
    let cameraPosition = cameraPositionPoint.intPoint
    print("camera: \(cameraPosition.x), \(cameraPosition.y)")
    if cameraStart.x == -9999 && cameraStart.y == -9999 {
      cameraStart = cameraPosition


    }
    if let player {
      print("player position: \(player.f.intPoint.x), \(player.f.intPoint.y)")
    }

//    Graphics.setDrawOffset(dx: Display.width/2 - cameraStart.x - cameraPosition.x,
//                           dy: Display.height/2 - cameraStart.y - cameraPosition.y)
    let dx = Display.width/2 - cameraPosition.x/2
    let dy = /*Display.height/2 - */cameraStart.y - cameraPosition.y/2 + Display.height/2
    print("d: \(dx), \(dy)")
    Graphics.setDrawOffset(dx: dx, dy: dy)
//    if let player {
//      cameraStart.x = Display.width/2 - player.f.intPoint.x/2
//      cameraStart.y = Display.height/2 - player.f.intPoint.y/2
//      print("player position: \(player.f.intPoint.x), \(player.f.intPoint.y)")
//      print("camera: \(cameraStart.x), \(cameraStart.y)")
//      Graphics.setDrawOffset(dx: cameraStart.x,
//                             dy: cameraStart.y)
//    }

//    if let player, cameraStart.x == -9999 && cameraStart.y == -9999 {
//      cameraStart.x = Display.width/2 - player.f.intPoint.x/2
//      cameraStart.y = Display.height/2 - player.f.intPoint.y/2
//    }
//    Graphics.setDrawOffset(dx: cameraStart.x,
//                           dy: cameraStart.y)

    // Update Playdate system
    Sprite.updateAndDrawDisplayListSprites()
    System.drawFPS()

    lastCurrentTimeMilliseconds = System.currentTimeMilliseconds
    print("-----")
    return true
  }



  func gameWillPause() {
    print("Paused!")
  }
}

