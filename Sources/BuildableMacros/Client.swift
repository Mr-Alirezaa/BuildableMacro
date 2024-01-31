import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct BuildableMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        BuildableMacro.self,
        BuildableTrackedMacro.self,
        BuildableIgnoredMacro.self,
    ]
}
