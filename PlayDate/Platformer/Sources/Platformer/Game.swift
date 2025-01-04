import PlaydateKit
//import PlatformerSystem

// MARK: - Game

final class Game: PlaydateGame {
  private(set) var gameManager = GameManager()
  let background: Background

  // MARK: Lifecycle

  init() {
//    logo.addToDisplayList()

//    AppState.load()
    gameManager.loadLevel()
//    setupBlocks()

    background = Background(allBlocks: gameManager.allBlocks())

    background.addToDisplayList()
  }

  // MARK: Internal

//  let logo = Logo()

  func update() -> Bool {
    Sprite.updateAndDrawDisplayListSprites()
    System.drawFPS()
    return true
  }
  
  func gameWillPause() {
    print("Paused!")
  }
}

