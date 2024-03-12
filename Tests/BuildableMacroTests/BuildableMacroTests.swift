#if canImport(BuildableMacros)
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting

import BuildableMacros

final class BuildableMacroTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
//            isRecording: true,
            macros: ["Buildable": BuildableMacro.self]
        ) {
            super.invokeTest()
        }
    }

    func testAddingBuildableTrackedToSettableProperties() throws {
        assertMacro {
            """
            @Buildable
            struct Sample {
                var p1: String
                var p2: String = ""
            }
            """
        } expansion: {
            """
            struct Sample {
                @BuildableTracked
                var p1: String
                @BuildableTracked
                var p2: String = ""
            }
            """
        }
    }

    func testPublicAccessControl() throws {
        assertMacro {
            """
            @Buildable
            public struct Sample {
                public var p1: String
                public var p2: String = ""
            }
            """
        } expansion: {
            """
            public struct Sample {
                @BuildableTracked
                public var p1: String
                @BuildableTracked
                public var p2: String = ""
            }
            """
        }
    }

    func testPrivateAccessControl() throws {
        assertMacro {
            """
            @Buildable
            struct Sample {
                private var p1: String
                private var p2: String = ""
            }
            """
        } expansion: {
            """
            struct Sample {
                @BuildableTracked
                private var p1: String
                @BuildableTracked
                private var p2: String = ""
            }
            """
        }
    }

    func testFunctionTypeProperties() throws {
        assertMacro {
            """
            @Buildable
            struct Sample {
                var p1: () -> Void
                var p2: (String) -> Void
                var p3: (String?) -> Void
                var p4: (String) -> String
                var p5: (String?) -> String?
                var p6: () -> String
                var p7: (() -> String)
                var p7: (() -> String)?
            }
            """
        } expansion: {
            """
            struct Sample {
                @BuildableTracked
                var p1: () -> Void
                @BuildableTracked
                var p2: (String) -> Void
                @BuildableTracked
                var p3: (String?) -> Void
                @BuildableTracked
                var p4: (String) -> String
                @BuildableTracked
                var p5: (String?) -> String?
                @BuildableTracked
                var p6: () -> String
                @BuildableTracked
                var p7: (() -> String)
                @BuildableTracked
                var p7: (() -> String)?
            }
            """
        }
    }

    func testSkippingAlreadyTrackedProperties() throws {
        assertMacro {
            """
            @Buildable
            struct Sample {
                @BuildableTracked
                var p1: String
                @BuildableTracked
                var p2: String = ""
            }
            """
        } expansion: {
            """
            struct Sample {
                @BuildableTracked
                var p1: String
                @BuildableTracked
                var p2: String = ""
            }
            """
        }
    }

    func testSkippingIgnoredProperties() throws {
        assertMacro {
            """
            @Buildable
            struct Sample {
                @BuildableIgnored
                var p3: String
                @BuildableIgnored
                var p4: String = ""
            }
            """
        } expansion: {
            """
            struct Sample {
                @BuildableIgnored
                var p3: String
                @BuildableIgnored
                var p4: String = ""
            }
            """
        }
    }

    func testSkippingConstantProperties() {
        assertMacro {
            """
            @Buildable
            struct Sample {
                let p1: String
                let p2: String = ""
            }
            """
        } expansion: {
            """
            struct Sample {
                let p1: String
                let p2: String = ""
            }
            """
        }
    }

    func testSkippingComputedProperties() {
        assertMacro {
            """
            @Buildable
            struct Sample {
                var p1: String { "ABC" }
                var p2: String {
                    "ABC"
                }
                var p3: Int { get { 0 } }
                var p4: Int {
                    get { 0 }
                }
            }
            """
        } expansion: {
            """
            struct Sample {
                var p1: String { "ABC" }
                var p2: String {
                    "ABC"
                }
                var p3: Int { get { 0 } }
                var p4: Int {
                    get { 0 }
                }
            }
            """
        }
    }

    func testSkippingStaticProperties() {
        assertMacro {
            """
            @Buildable
            struct Sample {
                static var s1: String = ""
                static var s2: Int?
            }
            """
        } expansion: {
            """
            struct Sample {
                static var s1: String = ""
                static var s2: Int?
            }
            """
        }
    }

    func testSkippingClassProperties() {
        assertMacro {
            """
            @Buildable
            class Sample {
                class var c1: String {
                    get { "" }
                    set { print(newValue) }
                }
            }
            """
        } expansion: {
            """
            class Sample {
                class var c1: String {
                    get { "" }
                    set { print(newValue) }
                }
            }
            """
        }
    }

    func testSkippingMultipleBindingsProperties() {
        assertMacro {
            """
            @Buildable
            struct Sample {
                var p1: String, p2: Int
            }
            """
        } expansion: {
            """
            struct Sample {
                var p1: String, p2: Int
            }
            """
        }
    }

    func testHandlingSettableComputedProperties() {
        assertMacro {
            """
            @Buildable
            struct Sample {
                var p1: Int {
                    get { 0 }
                    set { print(newValue) }
                }
            }
            """
        } expansion: {
            """
            struct Sample {
                @BuildableTracked
                var p1: Int {
                    get { 0 }
                    set { print(newValue) }
                }
            }
            """
        }
    }

    func testEmptyTypesHandling() throws {
        assertMacro {
            """
            @Buildable
            struct Sample {
            }
            """
        } expansion: {
            """
            struct Sample {
            }
            """
        }
    }

    func testNestedTypeHandling() throws {
        assertMacro {
            """
            @Buildable
            struct Outer {
                struct Inner {
                    var ip1: Int
                }
                var op1: String
            }
            struct Outer {
                @Buildable
                struct Inner {
                    var ip1: Int
                }
                var op1: String
            }
            """
        } expansion: {
            """
            struct Outer {
                struct Inner {
                    var ip1: Int
                }
                @BuildableTracked
                var op1: String
            }
            struct Outer {
                struct Inner {
                    @BuildableTracked
                    var ip1: Int
                }
                var op1: String
            }
            """
        }
    }

    func testErrorForEnums() throws {
        assertMacro {
            """
            @Buildable
            enum Outer {
                case c1
                case c2
                case c3
            }
            """
        } diagnostics: {
            """
            @Buildable
            ├─ 🛑 @Buildable can only be applied to nominal types (class, struct, and actors).
            ├─ 🛑 @Buildable can only be applied to nominal types (class, struct, and actors).
            ╰─ 🛑 @Buildable can only be applied to nominal types (class, struct, and actors).
            enum Outer {
                case c1
                case c2
                case c3
            }
            """
        }
    }

    func testErrorForProtocols() throws {
        assertMacro {
            """
            @Buildable
            protocol Outer {
                var p1: String { get }
                var p2: Int { get set }
            }
            """
        } diagnostics: {
            """
            @Buildable
            ├─ 🛑 @Buildable can only be applied to nominal types (class, struct, and actors).
            ╰─ 🛑 @Buildable can only be applied to nominal types (class, struct, and actors).
            protocol Outer {
                var p1: String { get }
                var p2: Int { get set }
            }
            """
        }
    }
}
#endif
