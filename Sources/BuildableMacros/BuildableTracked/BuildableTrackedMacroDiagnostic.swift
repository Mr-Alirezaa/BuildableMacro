import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

enum BuildableTrackedMacroDiagnostic {
    case nonVariableDeclaration
    case letConstant
    case getOnlyComputedProperty
}

extension BuildableTrackedMacroDiagnostic: DiagnosticMessage {
    var macroName: String { "BuildableTracked" }

    var severity: DiagnosticSeverity {
        return .error
    }

    var message: String {
        switch self {
        case .nonVariableDeclaration:
            "@\(macroName) can not be applied to non-variable declarations."
        case .letConstant:
            "@\(macroName) can not be applied to a \"let\" constant."
        case .getOnlyComputedProperty:
            "@\(macroName) can not be applied to a get-only computed property."
        }
    }

    var diagnosticID: MessageID {
        switch self {
        case .nonVariableDeclaration:
            MessageID(domain: macroName, id: "nonVariableDeclaration")
        case .letConstant:
            MessageID(domain: macroName, id: "letConstant")
        case .getOnlyComputedProperty:
            MessageID(domain: macroName, id: "getOnlyComputedProperty")
        }
    }
}
