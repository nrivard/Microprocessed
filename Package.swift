// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Microprocessed",
//    platforms: [
//        .iOS(.v13),
//        .macOS(.v10_15),
//        .tvOS(.v13)
//    ],
    products: [
        .library(
            name: "Microprocessed",
            targets: ["Microprocessed"])
    ],
    targets: [
        .target(
            name: "Microprocessed",
            dependencies: []),
        .testTarget(
            name: "MicroprocessedTests",
            dependencies: ["Microprocessed"]
        ),
        .testTarget(
            name: "MicroprocessedE2ETests",
            dependencies: ["Microprocessed"],
            resources: [
                .copy("6502_functional_test.bin"),
                .copy("65C02_extended_opcodes_test.bin"),
                .copy("65C02_decimal_test.bin")
            ]
        )
    ]
)
