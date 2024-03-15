// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "BuildableMacro",
    platforms: [
        .macOS("10.15"),
        .iOS("13.0"),
        .tvOS("13.0"),
        .watchOS("6.0"),
        .macCatalyst("13.0"),
        .visionOS("1.0")
    ],
    products: [
        .library(
            name: "BuildableMacro",
            targets: ["BuildableMacro"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", "509.0.0" ..< "511.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", from: "0.1.0"),
    ],
    targets: [
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "BuildableMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(
            name: "BuildableMacro",
            dependencies: ["BuildableMacros"],
            resources: [
                .process("../PrivacyInfo.xcprivacy"),
            ]
        ),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(
            name: "BuildableMacroClient",
            dependencies: ["BuildableMacro"],
            resources: [
                .process("../PrivacyInfo.xcprivacy"),
            ]
        ),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "BuildableMacroTests",
            dependencies: [
                "BuildableMacros",
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        ),
    ]
)
