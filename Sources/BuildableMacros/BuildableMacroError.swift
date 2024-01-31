import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

enum MacroDiagnostic {
    case nonNominalType
}

extension MacroDiagnostic: DiagnosticMessage {
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

    func diagnose<S: SyntaxProtocol>(at node: S) -> Diagnostic {
        Diagnostic(node: node, message: self)
    }
}
