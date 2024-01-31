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
                    var new = self
                    new.name = value
                    return new
                }
                var onChange: () -> Void

                func onChange(_ value: @escaping () -> Void) -> Self {
                    var new = self
                    new.onChange = value
                    return new
                }
                var score: Int, isMale: Bool

                func score(_ value: Int) -> Self {
                    var new = self
                    new.score = value
                    return new
                }

                func isMale(_ value: Bool) -> Self {
                    var new = self
                    new.isMale = value
                    return new
                }

                @BuildableIgnored
                var age: Int = ""
            }
            """
        }
    }
}

