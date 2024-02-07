/// A macro that marks a class, struct, or actor for automatic setter generation by applying
/// [@BuildableTracked](<doc:BuildableMacro/BuildableTracked(name:forceEscaping:)>) to properties.
///
/// It scans for settable properties and applies [`@Buildable`](<doc:BuildableMacro/Buildable()>) to them, unless marked
/// with [`@BuildableIgnored`](<doc:BuildableMacro/BuildableIgnored()>).
///
/// Example:
/// ```swift
/// @Buildable
/// struct User {
///     @BuildableIgnored
///     let id: UUID
///     var name: String
/// }
/// // Automatically adds @BuildableTracked to 'name' but not to 'id'.
/// ```
///
/// - Note: This macro is an entry point for the Buildable functionality.
@attached(memberAttribute)
public macro Buildable() = #externalMacro(
    module: "BuildableMacros",
    type: "BuildableMacro"
)

/// A macro that generates a fluent setter function for the annotated property.
///
/// [`@BuildableTracked`](<doc:BuildableMacro/BuildableTracked(name:forceEscaping:)>) can be applied to all settable
/// properties of nominal types (structs, classes, and actors). A setter function will be generated for every property
/// that is marked with [`@BuildableTracked`](<doc:BuildableMacro/BuildableTracked(name:forceEscaping:)>)
///
/// ```swift
/// struct Sample {
///     @BuildableTracked
///     var name: String
/// }
/// // Generates a function `func name(_ value: String) -> Self`.
/// ```
///
/// By default, name of the generated function is the same as the name of the property itself (Similar to what is widely
/// used in `SwiftUI`). You may override the default naming behavior by passing your desired name in `name` argument:
///
/// ```swift
/// struct Sample {
///     @BuildableTracked(name: "updateAge")
///     var age: Int
/// }
/// // Generates a function `func updateAge(_ value: Int) -> Self`.
/// ```
///
/// This macro checks for function types and automatically applies `@escaping` attribute if required. But in rare cases
/// (such as typealiases of function types), it may fail. You can set `forceEscaping` to true to bypass this limitation.
/// Here is an example:
///
/// ```swift
/// typealias CompletionHandler = () -> Void
/// struct Sample {
///     @BuildableTracked(forceEscaping: true)
///     var completionHandler: CompletionHandler
/// }
/// // Generates a function `func completionHandler(_ value: @escaping CompletionHandler) -> Self`.
/// ```
///
/// Here is an example with both custom `name` and `forceEscaping` parameters defined:
///
/// ```swift
/// typealias Handler = (String) -> Void
/// struct Sample {
///     @BuildableTracked(name: "setHandler", forceEscaping: true)
///     var handler: Handler
/// }
/// // Generates a function `func setHandler(_ value: @escaping Handler) -> Self`.
/// ```
///
/// - Parameters:
///   - name: Optional. Custom name for the generated setter function. Defaults to the property name.
///   - forceEscaping: Optional. Marks the parameter of the setter as `@escaping`. Useful for type aliases of function
///     types which are not identifiable by the macro. Defaults to false.
///
/// - Note: It’s used either directly or indirectly via [`@Buildable`](<doc:BuildableMacro/Buildable()>).
@attached(peer, names: arbitrary)
public macro BuildableTracked(
    name: StaticString? = nil,
    forceEscaping: Bool = false
) = #externalMacro(
    module: "BuildableMacros",
    type: "BuildableTrackedMacro"
)

/// A macro that excludes a property from being tracked and modified by [`@Buildable`](<doc:BuildableMacro/Buildable()>)
/// and [`@BuildableTracked`](<doc:BuildableMacro/BuildableTracked(name:forceEscaping:)>) macros.
///
/// Useful for properties that should remain immutable or not part of the fluent interface.
///
/// Example:
/// ```swift
/// @Buildable
/// struct Example {
///     @BuildableIgnored
///     var ignoredProperty: String
/// }
/// // 'ignoredProperty' is not marked with `@BuildableTracked`, so no setter will be generated for it.
/// ```
@attached(accessor, names: named(willSet))
public macro BuildableIgnored() = #externalMacro(
    module: "BuildableMacros",
    type: "BuildableIgnoredMacro"
)
