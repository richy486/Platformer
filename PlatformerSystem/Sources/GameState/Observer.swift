//
//  Observer.swift
//  Platformer
//
//  Created by Richard Adem on 08/01/2025.
//

final public class Observer: @unchecked Sendable {

  public static let shared = Observer()

  public struct Package {
    public let message: String
    public let point: IntPoint?
    public let tileType: TileTypeFlag?
  }
  var update: ((Package) -> Void)?

  /// Using unsafe pointers to avoid retain cycle, not sure if this is 100% correct.
  public func doUpdate<T: AnyObject>(from: T, update: @escaping (Package, T) -> Void) {

    // Not sure if the lifetime of `a` is guaranteed, it’s created on the init of `Game`
    // (with an instance of Game) and cast back to `Game` in the closure when an update arrives.
    let a = unsafeBitCast(from, to: Int.self)
    self.update = { package in
      let fromCast = unsafeBitCast(a, to: T.self)
      update(package, fromCast)
    }
  }
}
