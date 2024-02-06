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

    func test_BuildableTracked_whenAppliedToSettableProperties_generatesAppropriateSetterFunction() throws {
        assertMacro {
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
        } expansion: {
            """
            struct Sample {
                var p1: String

                func p1(_ value: String) -> Self {
                    var copy = self
                    copy.p1 = value
                    return copy
                }
                var p2: String = ""

                func p2(_ value: String) -> Self {
                    var copy = self
                    copy.p2 = value
                    return copy
                }
                var p3: String

                func p3(_ value: String) -> Self {
                    var copy = self
                    copy.p3 = value
                    return copy
                }
                var p4: String = ""

                func p4(_ value: String) -> Self {
                    var copy = self
                    copy.p4 = value
                    return copy
                }
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

                func p12(_ value: Int) -> Self {
                    var copy = self
                    copy.p12 = value
                    return copy
                }
                var p13: () -> Void

                func p13(_ value: @escaping () -> Void) -> Self {
                    var copy = self
                    copy.p13 = value
                    return copy
                }
                var p14: (String) -> Void

                func p14(_ value: @escaping (String) -> Void) -> Self {
                    var copy = self
                    copy.p14 = value
                    return copy
                }
                var p15: (String) -> String

                func p15(_ value: @escaping (String) -> String) -> Self {
                    var copy = self
                    copy.p15 = value
                    return copy
                }
                var p16: () -> String

                func p16(_ value: @escaping () -> String) -> Self {
                    var copy = self
                    copy.p16 = value
                    return copy
                }
            }
            """
        }
    }
}

