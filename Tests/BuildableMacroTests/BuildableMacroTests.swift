import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting

import BuildableMacros

final class BuildableMacroTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
            isRecording: true,
            macros: ["Buildable": BuildableMacro.self]
        ) {
            super.invokeTest()
        }
    }

    func testMacro() throws {
        assertMacro {
            """
            @Buildable(trackedByDefault: false)
            struct Person {
                var name: String = ""

                @BuildableTracked(label: "setLastName")
                var lastName: String = ""

                @BuildableIgnored
                var age: In = ""
            }
            """
        } expansion: {
            """
            struct Person {
                @BuildableIgnored
                var name: String = ""

                @BuildableTracked(label: "setLastName")
                var lastName: String = ""

                @BuildableIgnored
                var age: In = ""
            }
            """
        }
    }
}
