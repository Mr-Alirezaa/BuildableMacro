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
        guard let variableDecl = declaration.as(VariableDeclSyntax.self) else { return [] }
        let modifiers = variableDecl.modifiers

        var setters: [DeclSyntax] = []
        for binding in variableDecl.bindings {
            guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed,
                  let type = binding.typeAnnotation?.type.trimmed
            else { continue }

            let functionName = extractLabelName(from: node) ?? name
            let escaping: AttributeSyntax? = if type.is(FunctionTypeSyntax.self) { "@escaping " } else { nil }

            let setterFunction = try FunctionDeclSyntax("\(modifiers.trimmed)func \(functionName)(_ value: \(escaping)\(type)) -> Self") {
                "var copy = self"
                "copy.\(name) = value"
                "return copy"
            }

            setters.append(DeclSyntax(setterFunction))
        }

        return setters
    }

    private static func extractLabelName(from node: AttributeSyntax) -> TokenSyntax? {
        guard case let .argumentList(argList) = node.arguments,
              let labelArg = argList.first(where: { $0.label?.trimmedDescription == "name" }),
              let labelValue = labelArg.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
        else { return nil }

        return TokenSyntax.identifier(labelValue)
    }

    private static func diagnoseIssuesOf<DG: DeclGroupSyntax>(applying node: AttributeSyntax, to decl: DG) throws {
        var diagnostics: [Diagnostic] = []

        if let variableDecl = node.as(VariableDeclSyntax.self) {
            if variableDecl.bindingSpecifier.text == "let" {
                diagnostics.append(BuildableTrackedMacroDiagnostic.letConstant.diagnose(at: variableDecl.bindingSpecifier))
            }

            if let firstBinding = variableDecl.bindings.first, let accessors = firstBinding.accessorBlock?.accessors {
                switch accessors {
                case let .accessors(accessorList):
                    let specifiers = accessorList.map(\.accessorSpecifier.text)
                    if !specifiers.contains(anyOf: ["set", "_modify"]) {
                        diagnostics.append(BuildableTrackedMacroDiagnostic.getOnlyComputedProperty.diagnose(at: accessors))
                    }
                case .getter:
                    diagnostics.append(BuildableTrackedMacroDiagnostic.getOnlyComputedProperty.diagnose(at: accessors))
                }
            }
        } else {
            diagnostics.append(BuildableTrackedMacroDiagnostic.nonVariableDeclaration.diagnose(at: decl))
        }

        guard !diagnostics.isEmpty else { return }
        throw DiagnosticsError(diagnostics: diagnostics)
    }
}
