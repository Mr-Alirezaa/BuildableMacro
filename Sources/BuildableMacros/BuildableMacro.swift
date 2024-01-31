import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct BuildableMacro: MemberAttributeMacro {
    public static func expansion<DG: DeclGroupSyntax, D: DeclSyntaxProtocol, C: MacroExpansionContext>(
        of node: AttributeSyntax,
        attachedTo declaration: DG,
        providingAttributesFor member: D,
        in context: C
    ) throws -> [AttributeSyntax] {
        try diagnosticsOf(applying: node, to: declaration)

        guard let variableDecl = member.as(VariableDeclSyntax.self) else { return [] }

        // TODO: Check for get-only computed properties 

        let ignoredAttributeName = "BuildableIgnored"
        let trackedAttributeName = "BuildableTracked"

        let currentAttributeNames = variableDecl.attributes.compactMap {
            if case let .attribute(att) = $0 { att.attributeName.trimmedDescription } else { nil }
        }

        if currentAttributeNames.contains(ignoredAttributeName) || currentAttributeNames.contains(trackedAttributeName) {
            return []
        }

        return if trackedByDefault(node: node) {
            ["@\(raw: trackedAttributeName)"]
        } else {
            ["@\(raw: ignoredAttributeName)"]
        }
    }

    private static func trackedByDefault(node: AttributeSyntax) -> Bool {
        guard case let .argumentList(argList) = node.arguments,
              let trackedByDefaultArg = argList.first(where: { $0.label?.trimmedDescription == "trackedByDefault" }),
              let trackedByDefaultValue = trackedByDefaultArg.expression.as(BooleanLiteralExprSyntax.self)?.literal.trimmedDescription,
              let value = Bool(trackedByDefaultValue)
        else { return true }

        return value
    }

    private static func diagnosticsOf<DG: DeclGroupSyntax>(applying node: AttributeSyntax, to decl: DG) throws {
        if !decl.is(oneOf: [StructDeclSyntax.self, ClassDeclSyntax.self, ActorDeclSyntax.self]) {
//            throw Diagnos
        }
    }
}
