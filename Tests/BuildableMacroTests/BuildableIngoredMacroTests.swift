#if canImport(BuildableMacros)
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting

import BuildableMacros

final class BuildableIngoredMacroTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
//            isRecording: true,
            macros: ["BuildableIgnored": BuildableIgnoredMacro.self]
        ) {
            super.invokeTest()
        }
    }

    func testNoChangeForBuildableIgnoredProperties() throws {
        assertMacro {
            """
            struct Sample {
                @BuildableIgnored
                var p1: String
                @BuildableIgnored
                var p2: String = ""
            }
            """
        } expansion: {
            """
            struct Sample {
                var p1: String
                var p2: String = ""
            }
            """
        }
    }
}
#endif
