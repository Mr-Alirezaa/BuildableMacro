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
        try diagnoseIssuesOf(applying: node, to: declaration)

        guard let variableDecl = member.as(VariableDeclSyntax.self),
              variableDecl.bindingSpecifier.tokenKind == .keyword(.var),
              !variableDecl.modifiers.lazy.map(\.name.tokenKind).contains(anyOf: [.keyword(.static), .keyword(.class)]),
              variableDecl.bindings.count == 1
        else { return [] }

        let firstBinding = variableDecl.bindings.first!
        if let accessors = firstBinding.accessorBlock?.accessors {
            switch accessors {
            case let .accessors(accessorList):
                let specifiers = accessorList.lazy.map(\.accessorSpecifier.tokenKind)
                if !specifiers.contains(anyOf: [.keyword(.set), .keyword(._modify)]) {
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

        let attributeName: TypeSyntax = "\(raw: trackedAttributeName)"
        return [AttributeSyntax(attributeName: attributeName)]
    }

    private static func diagnoseIssuesOf<DG: DeclGroupSyntax>(applying node: AttributeSyntax, to decl: DG) throws {
        var diagnostics: [Diagnostic] = []
        if !decl.`is`(anyOf: [StructDeclSyntax.self, ClassDeclSyntax.self, ActorDeclSyntax.self]) {
            diagnostics.append(BuildableMacroDiagnostic.nonNominalType.diagnose(at: decl))
        }

        guard !diagnostics.isEmpty else { return }
        throw DiagnosticsError(diagnostics: diagnostics)
    }
}
