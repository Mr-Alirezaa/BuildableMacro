import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct BuildableTrackedMacro: PeerMacro {
    public static func expansion<D: DeclSyntaxProtocol, C: MacroExpansionContext>(
        of node: AttributeSyntax,
        providingPeersOf declaration: D,
        in context: C
    ) throws -> [DeclSyntax] {
        try diagnoseIssuesOf(applying: node, to: declaration)

        guard let variableDecl = declaration.as(VariableDeclSyntax.self) else { return [] }

        let modifier = lowestAccessLevelModifier(for: variableDecl)

        var setters: [DeclSyntax] = []
        for binding in variableDecl.bindings {
            guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed,
                  let type = binding.typeAnnotation?.type.trimmed
            else { continue }

            let functionName = try node.extractStringValue(for: "name") ?? name.text
            let forceEscaping = try node.extractBooleanValue(for: "forceEscaping") ?? false

            let escaping: AttributeSyntax? = if forceEscaping || type.requiresEscaping() { "@escaping " } else { nil }

            let setterFunction = try FunctionDeclSyntax("\(modifier)func \(raw: functionName)(_ value: \(escaping)\(type)) -> Self") {
                "var copy = self"
                "copy.\(name) = value"
                "return copy"
            }

            setters.append(DeclSyntax(setterFunction))
        }

        return setters
    }

    private static func lowestAccessLevelModifier(for decl: VariableDeclSyntax) -> DeclModifierSyntax? {
        if decl.modifiers.isEmpty { return nil }

        let modifiers = decl.modifiers.lazy.map(\.name)
        guard let name = modifiers.last(where: {
            guard case let .keyword(accessLevel) = $0.tokenKind else { return false }
            let accessLevels: [SwiftSyntax.Keyword] = [.private, .fileprivate, .internal, .package, .public, .open]
            return accessLevels.contains(accessLevel)
        }) else { return nil }

        return DeclModifierSyntax(name: name).with(\.trailingTrivia, .space)
    }

    private static func diagnoseIssuesOf<D: DeclSyntaxProtocol>(applying node: AttributeSyntax, to decl: D) throws {
        var diagnostics: [Diagnostic] = []

        if let variableDecl = decl.as(VariableDeclSyntax.self) {
            if variableDecl.bindingSpecifier.tokenKind == .keyword(.let) {
                diagnostics.append(BuildableTrackedMacroDiagnostic.letConstant.diagnose(at: variableDecl))
            }

            if variableDecl.modifiers.lazy.map(\.name.text).contains(anyOf: ["static", "class"]) {
                diagnostics.append(BuildableTrackedMacroDiagnostic.staticProperty.diagnose(at: variableDecl))
            }

            if let firstBinding = variableDecl.bindings.first, let accessors = firstBinding.accessorBlock?.accessors {
                switch accessors {
                case let .accessors(accessorList):
                    if accessorList.allSatisfy({ $0.body == nil }) {
                        diagnostics.append(
                            BuildableTrackedMacroDiagnostic.protocolProperty.diagnose(at: variableDecl)
                        )
                        break
                    }

                    let specifiers = accessorList.lazy.map(\.accessorSpecifier.text)
                    if !specifiers.contains(anyOf: ["set", "_modify"]) {
                        diagnostics.append(
                            BuildableTrackedMacroDiagnostic.getOnlyComputedProperty.diagnose(at: variableDecl)
                        )
                    }
                case .getter:
                    diagnostics.append(
                        BuildableTrackedMacroDiagnostic.getOnlyComputedProperty.diagnose(at: variableDecl)
                    )
                }
            }
        } else {
            diagnostics.append(BuildableTrackedMacroDiagnostic.nonVariableDeclaration.diagnose(at: decl))
        }

        guard !diagnostics.isEmpty else { return }
        throw DiagnosticsError(diagnostics: diagnostics)
    }
}
