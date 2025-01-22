# Platformer Play Date

From [template](https://github.com/finnvoor/PlaydateKit).

## How to Build
For detailed instructions and documentation on how to get started creating a game using PlaydateKit, see [here](https://finnvoor.github.io/PlaydateKit/documentation/playdatekit/).

1. run the `copyToPD.sh` script in the project root, do this every time you make a change to PlatformerSystem
1. Install a recent nightly [Swift](https://www.swift.org/download/#snapshots) toolchain that supports the Embedded experimental feature.
1. Install the [Playdate SDK](https://play.date/dev/).
1. Create a new repository using this template.
1. Build and run directly in the simulator using Xcode, or build using the command `swift package pdc`. When built using `swift package`, the built `pdx` game file will be located at `.build/plugins/PDCPlugin/outputs/PlaydateKitTemplate.pdx` and can be opened in the Playdate simulator. 
