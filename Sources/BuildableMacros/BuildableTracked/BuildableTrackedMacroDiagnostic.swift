import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

enum BuildableTrackedMacroDiagnostic {
    case nonVariableDeclaration
    case letConstant
    case getOnlyComputedProperty
    case protocolProperty
    case staticProperty
}

extension BuildableTrackedMacroDiagnostic: DiagnosticMessage {
    var macroName: String { "BuildableTracked" }

    var severity: DiagnosticSeverity {
        return .error
    }

    var message: String {
        switch self {
        case .nonVariableDeclaration:
            "@\(macroName) cannot be applied to non-variable declarations."
        case .letConstant:
            "@\(macroName) cannot be applied to a \"let\" constant."
        case .getOnlyComputedProperty:
            "@\(macroName) cannot be applied to a get-only computed property."
        case .protocolProperty:
            "@\(macroName) cannot be applied to a properties in a protocol declaration."
        case .staticProperty:
            "@\(macroName) cannot be applied to \"static\" or \"class\" properties."
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
        case .protocolProperty:
            MessageID(domain: macroName, id: "protocolProperty")
        case .staticProperty:
            MessageID(domain: macroName, id: "staticProperty")
        }
    }
}
