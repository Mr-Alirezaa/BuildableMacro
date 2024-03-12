import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

extension SyntaxNodeString.StringInterpolation {
    mutating func appendInterpolation<Node: SyntaxProtocol>(_ node: Node?) {
        if let node {
            self.appendInterpolation(node)
        }
    }
}

extension SyntaxProtocol {
    func `is`<C: Collection>(anyOf syntaxTypes: C) -> Bool where C.Element == SyntaxProtocol.Type {
        syntaxTypes.contains { self.is($0) }
    }
}

extension TypeSyntaxProtocol {
    func requiresEscaping() -> Bool {
        if self.is(FunctionTypeSyntax.self) {
            return true
        } else if
            let tuple = self.as(TupleTypeSyntax.self),
            tuple.elements.count == 1,
            let type = (tuple.elements.first?.type).flatMap(TypeSyntax.init) {
            return type.requiresEscaping()
        }
        return false
    }
}

extension AttributeSyntax {
    var argumentList: LabeledExprListSyntax? {
        if case let .argumentList(list) = arguments { list } else { nil }
    }

    func argument(named name: String) -> LabeledExprSyntax? {
        argumentList?.first(where: { $0.label?.text == name })
    }

    func extractBooleanValue(for argumentName: String) throws -> Bool? {
        guard let argument = argument(named: argumentName) else { return nil }

        guard let literalValue = argument.expression.as(BooleanLiteralExprSyntax.self)?.literal.trimmedDescription,
              let value = Bool(literalValue)
        else {
            let diagnostic = GeneralDiagnostic.unknownLiteralExpr(expectedType: Bool.self).diagnose(at: argument)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }

        return value
    }

    func extractStringValue(for argumentName: String) throws -> String? {
        guard let argument = argument(named: argumentName) else { return nil }

        guard let stringLiteralExpr = argument.expression.as(StringLiteralExprSyntax.self) else {
            let diagnostic = GeneralDiagnostic.unknownLiteralExpr(expectedType: String.self).diagnose(at: argument)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }

        // `String` arguments are typed `StaticString`. So they are known at compile-time and does not require
        // validation against interpolation

        return stringLiteralExpr.representedLiteralValue
    }
}

extension DiagnosticMessage {
    func diagnose<S: SyntaxProtocol>(at node: S) -> Diagnostic {
        Diagnostic(node: node, message: self)
    }
}
