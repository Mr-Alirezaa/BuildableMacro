import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

enum GeneralDiagnostic {
    case unknownLiteralExpr(expectedType: Any.Type)
}

extension GeneralDiagnostic: DiagnosticMessage {
    var severity: DiagnosticSeverity {
        return .error
    }

    var message: String {
        switch self {
        case let .unknownLiteralExpr(expectedType):
            "Expression is unknown. Value for the argument must be a literal of type \"\(expectedType)\""
        }
    }

    var diagnosticID: MessageID {
        switch self {
        case .unknownLiteralExpr:
            MessageID(domain: "General", id: "unknownExpression")
        }
    }
}
