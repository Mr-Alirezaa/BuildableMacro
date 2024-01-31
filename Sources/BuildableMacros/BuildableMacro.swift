import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct BuildableMacro: MemberAttributeMacro {
    static let trackedAttributeName = "BuildableTracked"
    static let ignoredAttributeName = "BuildableIgnored"

    public static func expansion<DG: DeclGroupSyntax, D: DeclSyntaxProtocol, C: MacroExpansionContext>(
        of node: AttributeSyntax,
        attachedTo declaration: DG,
        providingAttributesFor member: D,
        in context: C
    ) throws -> [AttributeSyntax] {
        try diagnosticsOf(applying: node, to: declaration)

        guard let variableDecl = member.as(VariableDeclSyntax.self),
              variableDecl.bindingSpecifier.text == "var"
        else { return [] }

        if let firstBinding = variableDecl.bindings.first, let accessors = firstBinding.accessorBlock?.accessors {
            switch accessors {
            case let .accessors(accessorList):
                let specifiers = accessorList.map(\.accessorSpecifier.text)
                if !specifiers.contains(anyOf: ["set", "_modify"]) {
                    return []
                }
            case .getter:
                return []
            }
        }

        let currentAttributeNames = variableDecl.attributes.compactMap {
            if case let .attribute(att) = $0 { att.attributeName.trimmedDescription } else { nil }
        }

        if currentAttributeNames.contains(anyOf: [ignoredAttributeName, trackedAttributeName]) {
            return []
        }

        let tracked = trackedByDefault(node: node)
        let attributeName: TypeSyntax = "\(raw: tracked ? trackedAttributeName : ignoredAttributeName)"
        return [AttributeSyntax(attributeName: attributeName)]
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
        var diagnostics: [Diagnostic] = []
        if !decl.`is`(anyOf: [StructDeclSyntax.self, ClassDeclSyntax.self, ActorDeclSyntax.self]) {
            diagnostics.append(BuildableMacroDiagnostic.nonNominalType.diagnose(at: decl))
        }

        guard !diagnostics.isEmpty else { return }
        throw DiagnosticsError(diagnostics: diagnostics)
    }
}
