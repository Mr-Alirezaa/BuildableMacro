import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension SyntaxNodeString.StringInterpolation {
    mutating func appendInterpolation<Node: SyntaxProtocol>(_ node: Node?) {
        if let node {
            self.appendInterpolation(node)
        }
    }
}
extension SyntaxProtocol {
    func `is`<C: Collection>(anyOf syntaxTypes: C) -> Bool where C.Element == SyntaxProtocol.Type {
        syntaxTypes.contains { self.is($0) }
    }
}
extension Collection where Element: Equatable {
    func contains<C: Collection>(anyOf collection: C) -> Bool where C.Element == Element {
        contains(where: { collection.contains($0) })
    }
}
