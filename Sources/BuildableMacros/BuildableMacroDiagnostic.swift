import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

enum BuildableMacroDiagnostic {
    case nonNominalType
}

extension BuildableMacroDiagnostic: DiagnosticMessage {
    var macroName: String { "Buildable" }

    var severity: DiagnosticSeverity {
        return .error
    }

    var message: String {
        switch self {
        case .nonNominalType:
            "@\(macroName) can only be applied to nominal types (class, struct, and actors)."
        }
    }

    var diagnosticID: MessageID {
        switch self {
        case .nonNominalType:
            MessageID(domain: macroName, id: "nonNominalType")
        }
    }
}
