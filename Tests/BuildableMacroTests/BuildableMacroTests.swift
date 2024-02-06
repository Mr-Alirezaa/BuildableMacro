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

    func test_Buildable_whenAppliedToStruct_addsBuildableTrackedToSettableProperties() throws {
        assertMacro {
            """
            @Buildable
            struct Sample {
                var p1: String
                var p2: String = ""
                @BuildableTracked
                var p3: String
                @BuildableTracked
                var p4: String = ""
                @BuildableIgnored
                var p5: Int
                @BuildableIgnored
                var p6: Int = 0
                let p7: Data
                let p8: Data = Data()
                var p9: Int { 0 }
                var p10: Int {
                    0
                }
                var p11: Int {
                    get { 0 }
                }
                var p12: Int {
                    get { 0 }
                    set { print(newValue) }
                }
                var p13: () -> Void
                var p14: (String) -> Void
                var p15: (String) -> String
                var p16: () -> String
            }
            """
        } expansion: {
            """
            struct Sample {
                @BuildableTracked
                var p1: String
                @BuildableTracked
                var p2: String = ""
                @BuildableTracked
                var p3: String
                @BuildableTracked
                var p4: String = ""
                @BuildableIgnored
                var p5: Int
                @BuildableIgnored
                var p6: Int = 0
                let p7: Data
                let p8: Data = Data()
                var p9: Int { 0 }
                var p10: Int {
                    0
                }
                var p11: Int {
                    get { 0 }
                }
                @BuildableTracked
                var p12: Int {
                    get { 0 }
                    set { print(newValue) }
                }
                @BuildableTracked
                var p13: () -> Void
                @BuildableTracked
                var p14: (String) -> Void
                @BuildableTracked
                var p15: (String) -> String
                @BuildableTracked
                var p16: () -> String
            }
            """
        }
    }

    func test_Buildable_whenAppliedToTypealias_failsWithProperError() throws {
        assertMacro {
            """
            @Buildable
            typealias Sample = Int
            """
        } expansion: {
            """
            typealias Sample = Int
            """
        }
    }
}
