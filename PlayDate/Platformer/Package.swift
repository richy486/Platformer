// swift-tools-version: 6.0

// import Foundation
import PackageDescription


let package = Package(
    name: "Platformer",
    platforms: [.macOS(.v14)],
    products: [
      .library(name: "Platformer", targets: ["Platformer"]),
//      .library(name: "PlatformerSystem", targets: ["PlatformerSystem"]),
    ],
    dependencies: [
        .package(url: "https://github.com/finnvoor/PlaydateKit.git", branch: "main"),
//        .package(path: "../../PlatformerSystem/Sources")
    ],
    targets: [
        .target(
            name: "Platformer",
            dependencies: [
                .product(name: "PlaydateKit", package: "PlaydateKit"),
//                .product(name: "PlatformerSystem", package: "PlatformerSystem"),
            ],
            // path: "Sources",
            swiftSettings: swiftSettings
        )
        // .target(name: "PlatformerSystem", path: "../../PlatformerSystem/*")
    ],
    swiftLanguageModes: [.v6]
)


// MARK: - Helper Variables
// note: These must be computed variables when beneath the `let package =` declaration.

var swiftSettings: [SwiftSetting] {[
    .enableExperimentalFeature("Embedded"),
    .unsafeFlags([
        "-whole-module-optimization",
        "-Xfrontend", "-disable-objc-interop",
        "-Xfrontend", "-disable-stack-protector",
        "-Xfrontend", "-function-sections",
        "-Xfrontend", "-gline-tables-only",
//        "-Xfrontend", "-strict-concurrency=targeted",
//        "-Xfrontend", "-warn-concurrency",
        "-Xcc", "-DTARGET_EXTENSION",
        "-Xcc", "-I", "-Xcc", "\(gccIncludePrefix)/include",
        "-Xcc", "-I", "-Xcc", "\(gccIncludePrefix)/include-fixed",
        "-Xcc", "-I", "-Xcc", "\(gccIncludePrefix)/../../../../arm-none-eabi/include",
        "-I", "\(playdateSDKPath)/C_API"
    ]),
]}
var gccIncludePrefix: String {
    "/usr/local/playdate/gcc-arm-none-eabi-9-2019-q4-major/lib/gcc/arm-none-eabi/9.2.1"
}
var playdateSDKPath: String {
    if let path = Context.environment["PLAYDATE_SDK_PATH"] {
        return path
    }
    return "\(Context.environment["HOME"]!)/Developer/PlaydateSDK/"
}
