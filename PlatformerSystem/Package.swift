// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "PlatformerSystem",
  platforms: [
    // Add support for all platforms starting from a specific version.
    .macOS(.v11),
//    .iOS(.v13),
//    .watchOS(.v9),
//    .tvOS(.v16)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(name: "PlatformerSystem", targets: ["PlatformerSystem"])
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "PlatformerSystem"
//      path: "."
    ),
    // .testTarget(name: "PlatformerSystemTests", dependencies: ["PlatformerSystem"]),
  ]
)
