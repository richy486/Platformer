import PlaydateKit

/// Boilerplate entry code
nonisolated(unsafe) var game: Game!
@_cdecl("eventHandler") func eventHandler(
  pointer: UnsafeMutableRawPointer!,
  event: System.Event,
  _: CUnsignedInt
) -> CInt {
  switch event {
    case .initialize:
      Playdate.initialize(with: pointer)
      print("Create Game")
      game = Game()
      System.updateCallback = game.update
    default: game.handle(event)
  }
  return 0
}
