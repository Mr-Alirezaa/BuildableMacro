import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting

import BuildableMacros

final class BuildableMacroTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
            isRecording: false,
            macros: ["Buildable": BuildableMacro.self]
        ) {
            super.invokeTest()
        }
    }

    /// Validates that the @Buildable macro correctly adds @BuildableTracked to simple settable properties within a 
    /// struct.
    func testBuildableAddsTrackedToSettableProperties() throws {
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

    /// Ensures @Buildable properly handles multiple property declarations in a single line, tagging them all as
    /// @BuildableTracked.
    func testBuildableAddsTrackedToSettableOneForMultipleBindings() throws {
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
                @BuildableTracked
                var p1: String, p2: Int
            }
            """
        }
    }

    /// Tests the @Buildable macro's behavior with publicly accessible properties, checking if it correctly applies
    /// @BuildableTracked while maintaining the public access specifier.
    func testBuildableWithPublicAccessControl() throws {
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

    /// Checks if @Buildable respects private access control, adding @BuildableTracked to private properties without
    /// altering their access level.
    func testBuildableWithPrivateAccessControl() throws {
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

    /// Verifies that @Buildable can handle properties with function types, correctly tagging them with
    /// @BuildableTracked.
    func testBuildableWithFunctionTypeProperties() throws {
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

    /// Confirms that @Buildable does not redundantly apply @BuildableTracked to properties that are already explicitly 
    /// marked as such.
    func testBuildableSkipsAlreadyTrackedProperties() throws {
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

    /// Ensures that properties marked with @BuildableIgnored are correctly skipped by the @Buildable macro, not
    /// receiving the @BuildableTracked tag.
    func testBuildableSkipsIgnoredProperties() throws {
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

    /// Tests that constant properties (declared with 'let') are appropriately ignored by @Buildable, not receiving the
    /// @BuildableTracked tag.
    func testBuildableSkipsConstantProperties() {
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

    /// Verifies that computed properties do not receive the @BuildableTracked tag, as they are not suitable for such 
    /// modification.
    func testBuildableSkipsComputedProperties() {
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

    /// Checks whether @Buildable correctly handles computed properties with a setter, applying @BuildableTracked 
    /// appropriately.
    func testBuildableHandlesSettableComputedProperties() {
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

    /// Ensures that the @Buildable macro can be applied to types without properties, such as an empty struct, without
    /// causing issues.
    func testBuildableHandlesEmptyTypes() throws {
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

    /// Verifies the functionality of @Buildable in a scenario where nested types are involved, ensuring proper
    /// application of @BuildableTracked within nested structures.
    func testBuildableHandlesNestedTypes() throws {
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

    /// Confirms that applying the @Buildable macro to an enum type correctly results in a compile-time error, as enums
    /// are not supported.
    func testBuildableThrowsErrorForEnums() throws {
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

    /// Checks that applying @Buildable to a protocol also results in a compile-time error, asserting that the macro is
    /// only applicable to nominal types like classes, structs, and actors.
    func testBuildableThrowsErrorForProtocols() throws {
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
