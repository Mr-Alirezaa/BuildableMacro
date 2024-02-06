@attached(memberAttribute)
public macro Buildable() = #externalMacro(
    module: "BuildableMacros",
    type: "BuildableMacro"
)

@attached(peer, names: arbitrary)
public macro BuildableTracked(
    name: StaticString? = nil,
    forceEscaping: Bool = false
) = #externalMacro(
    module: "BuildableMacros",
    type: "BuildableTrackedMacro"
)

@attached(accessor, names: named(willSet))
public macro BuildableIgnored() = #externalMacro(
    module: "BuildableMacros",
    type: "BuildableIgnoredMacro"
)
