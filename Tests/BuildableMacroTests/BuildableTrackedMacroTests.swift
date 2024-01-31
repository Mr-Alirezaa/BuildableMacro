import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting

import BuildableMacros

final class BuildableTrackedMacroTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
            isRecording: true,
            macros: ["BuildableTracked": BuildableTrackedMacro.self]
        ) {
            super.invokeTest()
        }
    }

    func testMacro() throws {
        assertMacro {
            """
            struct Person {
                @BuildableTracked(label: "setName")
                var name: String = ""

                @BuildableTracked
                var onChange: () -> Void

                @BuildableTracked
                var score: Int, isMale: Bool

                @BuildableIgnored
                var age: Int = ""
            }
            """
        } expansion: {
            """
            struct Person {
                var name: String = ""

                func name(_ value: String) -> Self {
                    var copy = self
                    copy.name = value
                    return copy
                }
                var onChange: () -> Void

                func onChange(_ value: @escaping () -> Void) -> Self {
                    var copy = self
                    copy.onChange = value
                    return copy
                }
                var score: Int, isMale: Bool

                func score(_ value: Int) -> Self {
                    var copy = self
                    copy.score = value
                    return copy
                }

                func isMale(_ value: Bool) -> Self {
                    var copy = self
                    copy.isMale = value
                    return copy
                }

                @BuildableIgnored
                var age: Int = ""
            }
            """
        }
    }
}

