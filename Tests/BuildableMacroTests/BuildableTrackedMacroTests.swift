#if canImport(BuildableMacros)
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting

import BuildableMacros

final class BuildableTrackedMacroTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
            isRecording: false,
            macros: ["BuildableTracked": BuildableTrackedMacro.self]
        ) {
            super.invokeTest()
        }
    }

    func testSetterCreationForProperties() throws {
        assertMacro {
            """
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
            }
            """
        }
    }

    func testCustomNameForSetters() throws {
        assertMacro {
            """
            struct Sample {
                @BuildableTracked(name: "setP1")
                var p1: String
                @BuildableTracked(name: "setP2")
                var p2: String = ""
            }
            """
        } expansion: {
            """
            struct Sample {
                var p1: String

                func setP1(_ value: String) -> Self {
                    var copy = self
                    copy.p1 = value
                    return copy
                }
                var p2: String = ""

                func setP2(_ value: String) -> Self {
                    var copy = self
                    copy.p2 = value
                    return copy
                }
            }
            """
        }
    }

    func testForceEscapingForFunctionTypes() throws {
        assertMacro {
            """
            typealias AliasedFunctionType = () -> Void
            struct Sample {
                @BuildableTracked(forceEscaping: true)
                var p1: AliasedFunctionType
                @BuildableTracked(name: "setP2", forceEscaping: true)
                var p2: AliasedFunctionType
            }
            """
        } expansion: {
            """
            typealias AliasedFunctionType = () -> Void
            struct Sample {
                var p1: AliasedFunctionType

                func p1(_ value: @escaping AliasedFunctionType) -> Self {
                    var copy = self
                    copy.p1 = value
                    return copy
                }
                var p2: AliasedFunctionType

                func setP2(_ value: @escaping AliasedFunctionType) -> Self {
                    var copy = self
                    copy.p2 = value
                    return copy
                }
            }
            """
        }
    }

    func testMultipleSettersForMultiBindings() throws {
        assertMacro {
            """
            struct Sample {
                @BuildableTracked
                var p1: String, p2: Int
            }
            """
        } expansion: {
            """
            struct Sample {
                var p1: String, p2: Int

                func p1(_ value: String) -> Self {
                    var copy = self
                    copy.p1 = value
                    return copy
                }

                func p2(_ value: Int) -> Self {
                    var copy = self
                    copy.p2 = value
                    return copy
                }
            }
            """
        }
    }

    func testPublicAccessControlSetters() throws {
        assertMacro {
            """
            public struct Sample {
                @BuildableTracked
                public var p1: String
                @BuildableTracked
                public var p2: String = ""
            }
            """
        } expansion: {
            """
            public struct Sample {
                public var p1: String

                public func p1(_ value: String) -> Self {
                    var copy = self
                    copy.p1 = value
                    return copy
                }
                public var p2: String = ""

                public func p2(_ value: String) -> Self {
                    var copy = self
                    copy.p2 = value
                    return copy
                }
            }
            """
        }
    }

    func testPrivateAccessControlSetters() throws {
        assertMacro {
            """
            struct Sample {
                @BuildableTracked
                private var p1: String
                @BuildableTracked
                private var p2: String = ""
            }
            """
        } expansion: {
            """
            struct Sample {
                private var p1: String

                private func p1(_ value: String) -> Self {
                    var copy = self
                    copy.p1 = value
                    return copy
                }
                private var p2: String = ""

                private func p2(_ value: String) -> Self {
                    var copy = self
                    copy.p2 = value
                    return copy
                }
            }
            """
        }
    }

    func testPrivateSetAccessControlSetters() throws {
        assertMacro {
            """
            struct Sample {
                @BuildableTracked
                private(set) var p1: String
                @BuildableTracked
                private(set) var p2: String = ""
            }
            """
        } expansion: {
            """
            struct Sample {
                private(set) var p1: String

                private func p1(_ value: String) -> Self {
                    var copy = self
                    copy.p1 = value
                    return copy
                }
                private(set) var p2: String = ""

                private func p2(_ value: String) -> Self {
                    var copy = self
                    copy.p2 = value
                    return copy
                }
            }
            """
        }
    }

    func testPublicPrivateSetAccessControlSetters() throws {
        assertMacro {
            """
            public struct Sample {
                @BuildableTracked
                public private(set) var p1: String
                @BuildableTracked
                public private(set) var p2: String = ""
            }
            """
        } expansion: {
            """
            public struct Sample {
                public private(set) var p1: String

                private func p1(_ value: String) -> Self {
                    var copy = self
                    copy.p1 = value
                    return copy
                }
                public private(set) var p2: String = ""

                private func p2(_ value: String) -> Self {
                    var copy = self
                    copy.p2 = value
                    return copy
                }
            }
            """
        }
    }

    func testEscapingSettersForFunctionTypes() throws {
        assertMacro {
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
                var p8: ((() -> String))
            }
            """
        } expansion: {
            """
            struct Sample {
                var p1: () -> Void

                func p1(_ value: @escaping () -> Void) -> Self {
                    var copy = self
                    copy.p1 = value
                    return copy
                }
                var p2: (String) -> Void

                func p2(_ value: @escaping (String) -> Void) -> Self {
                    var copy = self
                    copy.p2 = value
                    return copy
                }
                var p3: (String?) -> Void

                func p3(_ value: @escaping (String?) -> Void) -> Self {
                    var copy = self
                    copy.p3 = value
                    return copy
                }
                var p4: (String) -> String

                func p4(_ value: @escaping (String) -> String) -> Self {
                    var copy = self
                    copy.p4 = value
                    return copy
                }
                var p5: (String?) -> String?

                func p5(_ value: @escaping (String?) -> String?) -> Self {
                    var copy = self
                    copy.p5 = value
                    return copy
                }
                var p6: () -> String

                func p6(_ value: @escaping () -> String) -> Self {
                    var copy = self
                    copy.p6 = value
                    return copy
                }
                var p7: (() -> String)

                func p7(_ value: @escaping (() -> String)) -> Self {
                    var copy = self
                    copy.p7 = value
                    return copy
                }
                var p8: ((() -> String))

                func p8(_ value: @escaping ((() -> String))) -> Self {
                    var copy = self
                    copy.p8 = value
                    return copy
                }
            }
            """
        }
    }

    func testNonEscapingSettersForOptionalFunctionTypes() throws {
        assertMacro {
            """
            struct Sample {
                @BuildableTracked
                var p1: (() -> String)?
                @BuildableTracked
                var p2: ((Int) -> String)?
                @BuildableTracked
                var p3: (() -> String, Int)
                @BuildableTracked
                var p4: (() -> String, (Int) throws -> Void)
            }
            """
        } expansion: {
            """
            struct Sample {
                var p1: (() -> String)?

                func p1(_ value: (() -> String)?) -> Self {
                    var copy = self
                    copy.p1 = value
                    return copy
                }
                var p2: ((Int) -> String)?

                func p2(_ value: ((Int) -> String)?) -> Self {
                    var copy = self
                    copy.p2 = value
                    return copy
                }
                var p3: (() -> String, Int)

                func p3(_ value: (() -> String, Int)) -> Self {
                    var copy = self
                    copy.p3 = value
                    return copy
                }
                var p4: (() -> String, (Int) throws -> Void)

                func p4(_ value: (() -> String, (Int) throws -> Void)) -> Self {
                    var copy = self
                    copy.p4 = value
                    return copy
                }
            }
            """
        }
    }

    func testSettersForSettableComputedProperties() {
        assertMacro {
            """
            struct Sample {
                @BuildableTracked
                var p1: Int {
                    get { 0 }
                    set { print(newValue) }
                }
            }
            """
        } expansion: {
            """
            struct Sample {
                var p1: Int {
                    get { 0 }
                    set { print(newValue) }
                }

                func p1(_ value: Int) -> Self {
                    var copy = self
                    copy.p1 = value
                    return copy
                }
            }
            """
        }
    }

    func testNestedTypeHandling() throws {
        assertMacro {
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
        } expansion: {
            """
            struct Outer {
                struct Inner {
                    var ip1: Int
                }
                var op1: String

                func op1(_ value: String) -> Self {
                    var copy = self
                    copy.op1 = value
                    return copy
                }
            }
            struct Outer {
                struct Inner {
                    var ip1: Int

                    func ip1(_ value: Int) -> Self {
                        var copy = self
                        copy.ip1 = value
                        return copy
                    }
                }
                var op1: String
            }
            """
        }
    }

    func testErrorForConstantProperties() throws {
        assertMacro {
            """
            struct Sample {
                @BuildableTracked
                let p1: String
                @BuildableTracked
                let p2: String = ""
            }
            """
        } diagnostics: {
            """
            struct Sample {
                @BuildableTracked
                ╰─ 🛑 @BuildableTracked can not be applied to a "let" constant.
                let p1: String
                @BuildableTracked
                ╰─ 🛑 @BuildableTracked can not be applied to a "let" constant.
                let p2: String = ""
            }
            """
        }
    }

    func testErrorForGetOnlyProperties() throws {
        assertMacro {
            """
            struct Sample {
                @BuildableTracked
                var p1: String { "ABC" }
                @BuildableTracked
                var p2: String {
                    "ABC"
                }
                @BuildableTracked
                var p3: Int { get { 0 } }
                @BuildableTracked
                var p4: Int {
                    get { 0 }
                }
            }
            """
        } diagnostics: {
            """
            struct Sample {
                @BuildableTracked
                ╰─ 🛑 @BuildableTracked can not be applied to a get-only computed property.
                var p1: String { "ABC" }
                @BuildableTracked
                ╰─ 🛑 @BuildableTracked can not be applied to a get-only computed property.
                var p2: String {
                    "ABC"
                }
                @BuildableTracked
                ╰─ 🛑 @BuildableTracked can not be applied to a get-only computed property.
                var p3: Int { get { 0 } }
                @BuildableTracked
                ╰─ 🛑 @BuildableTracked can not be applied to a get-only computed property.
                var p4: Int {
                    get { 0 }
                }
            }
            """
        }
    }

    func testErrorForEnumCases() throws {
        assertMacro {
            """
            enum Outer {
                @BuildableTracked
                case c1
                @BuildableTracked
                case c2
                @BuildableTracked
                case c3
            }
            """
        } diagnostics: {
            """
            enum Outer {
                @BuildableTracked
                ╰─ 🛑 @BuildableTracked can not be applied to non-variable declarations.
                case c1
                @BuildableTracked
                ╰─ 🛑 @BuildableTracked can not be applied to non-variable declarations.
                case c2
                @BuildableTracked
                ╰─ 🛑 @BuildableTracked can not be applied to non-variable declarations.
                case c3
            }
            """
        }
    }

    func testErrorForProtocolProperties() throws {
        assertMacro {
            """
            protocol Outer {
                @BuildableTracked
                var p1: String { get }
                @BuildableTracked
                var p2: Int { get set }
            }
            """
        } diagnostics: {
            """
            protocol Outer {
                @BuildableTracked
                ╰─ 🛑 @BuildableTracked can not be applied to a properties in a protocol declaration.
                var p1: String { get }
                @BuildableTracked
                ╰─ 🛑 @BuildableTracked can not be applied to a properties in a protocol declaration.
                var p2: Int { get set }
            }
            """
        }
    }

    func testErrorForFunctions() throws {
        assertMacro {
            """
            struct Sample {
                @BuildableTracked
                func f1() -> String { "" }
            }
            @BuildableTracked
            func f2() -> Int { 0 }
            """
        } diagnostics: {
            """
            struct Sample {
                @BuildableTracked
                ╰─ 🛑 @BuildableTracked can not be applied to non-variable declarations.
                func f1() -> String { "" }
            }
            @BuildableTracked
            ╰─ 🛑 @BuildableTracked can not be applied to non-variable declarations.
            func f2() -> Int { 0 }
            """
        }
    }

    func testErrorForStructAnnotation() throws {
        assertMacro {
            """
            @BuildableTracked
            struct Sample {
                var p1: String
            }
            """
        } diagnostics: {
            """
            @BuildableTracked
            ╰─ 🛑 @BuildableTracked can not be applied to non-variable declarations.
            struct Sample {
                var p1: String
            }
            """
        }
    }

    func testErrorForNonLiteralCustomNameForSetters() throws {
        assertMacro {
            """
            let name = "setP1"
            struct Sample {
                @BuildableTracked(name: name)
                var p1: String
            }
            """
        } diagnostics: {
            """
            let name = "setP1"
            struct Sample {
                @BuildableTracked(name: name)
                                  ┬─────────
                                  ╰─ 🛑 Expression is unknown. Value for the argument must be a literal of type "String"
                var p1: String
            }
            """
        }
    }

    func testErrorForNonLiteralForceEscapingValue() throws {
        assertMacro {
            """
            typealias AliasedFunctionType = () -> Void
            let value = true
            struct Sample {
                @BuildableTracked(forceEscaping: value)
                var p1: AliasedFunctionType
            }
            """
        } diagnostics: {
            """
            typealias AliasedFunctionType = () -> Void
            let value = true
            struct Sample {
                @BuildableTracked(forceEscaping: value)
                                  ┬───────────────────
                                  ╰─ 🛑 Expression is unknown. Value for the argument must be a literal of type "Bool"
                var p1: AliasedFunctionType
            }
            """
        }
    }
}
#endif
