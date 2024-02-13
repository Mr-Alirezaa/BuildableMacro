# BuildableMacro

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMr-Alirezaa%2FBuildableMacro%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Mr-Alirezaa/BuildableMacro) 
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FMr-Alirezaa%2FBuildableMacro%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Mr-Alirezaa/BuildableMacro)

BuildableMacro is a Swift package inspired by Apple's [SwiftUI](https://developer.apple.com/documentation/swiftui) and [Observation](https://developer.apple.com/documentation/observation) frameworks, simplifying property modification in Swift through automated fluent setter function generation.

## Overview

BuildableMacro is a Swift package designed to enhance the way properties are modified and managed in Swift. Drawing inspiration from Apple's [Observation framework](https://developer.apple.com/documentation/observation), it introduces a set of macros that streamline the property modification process, making it more intuitive and fluent. The package's main feature is its ability to automatically generate setter functions for properties, following a pattern similar to [SwiftUI](https://developer.apple.com/documentation/swiftui)'s modifier approach.

This approach not only makes the code more readable but also maintains the familiarity for Swift developers accustomed to the [SwiftUI framework](https://developer.apple.com/documentation/swiftui). 

## Features

The package includes `@Buildable`, `@BuildableTracked`, and `@BuildableIgnored` macros, each serving a specific purpose in the property modification workflow. `@BuildableTracked`, for example, creates fluent setter functions, which can be customized with desired names, whereas `@BuildableIgnored` excludes certain properties from this automated process, providing developers with control over their code structure and behavior.

### `@Buildable`

Automates the marking of settable properties as `@BuildableTracked`, excluding those marked as `@BuildableIgnored`.

The `@Buildable` macro selectively applies `@BuildableTracked` to eligible properties. It skips constants, computed properties without setters, and those marked as `@BuildableIgnored`, ensuring only suitable properties are modified.

### `@BuildableTracked`

Generates setter functions for each marked property, allowing fluent chaining of modifications.

In `@BuildableTracked`, a custom name for the generated setter function can be specified through the `name` parameter. This allows for more descriptive and context-specific naming of setter functions, enhancing code clarity and expressiveness.

Although `@BuildableTracked` automatically recognizes function types and adds `@escaping` attribute to the generated functions, the `forceEscaping` parameter ensures correct handling of type aliases for function types. It marks parameters as `@escaping` when needed, ensuring closure and callback patterns are treated accurately, crucial for asynchronous or callback-based code structures.

### `@BuildableIgnored`

Excludes properties from automatic setter function generation.

## Usage

Apply the `@Buildable` macro to a type (class, struct, or actor) to automatically generate fluent setter functions for its properties. Customize the behavior using `@BuildableTracked` and `@BuildableIgnored` macros.

```swift
@Buildable
struct Team {
    @BuildableIgnored
    var name: String
    var nickname: String?
    @BuildableTracked(name: "updateSponsor")
    var sponser: Sponser?
    var owner: Person
    var players: [Person]
    var coach: Person
}

// Old AFC Richmond team:
let afcRichmond = Team(
    name: "AFC Richmond"
    nickname: "The Greyhounds"
    sponser: "Dubai Air"
    owner: Person(name: "Rupert Mannion")
    players: [...]
    coach: Person(name: "George Cartrick")
)

// Change some properties easily by calling generated setter functions to assign new values. (Similar to SwiftUI)
let newAFCRichmond = afcRichmond
    .owner(Person(name: "Rebecca Welton"))
    .coach(Person(name: "Ted Lasso"))
    .updateSponsor(Sponsor(name: "Bantr")) // -> function name is customized by setting`name` property in @BuildableTracked() macro.
    // .name("Crystal Palace") -> This cannot be called since the related property, "name", is ignored and no setter is created for it.
```

## Installation

### Swift Package Manager

BuildableMacro is available through [Swift Package Manager](https://www.swift.org/package-manager/). To install
it, simply add the package to the dependencies of your Package.swift file:

```swift
dependencies: [
    .package(url: "https://github.com/Mr-Alirezaa/BuildableMacro.git", from: "0.2.0"),
]
```

Normally you'll want to depend on the `BuildableMacro` target:

```swift
.product(name: "BuildableMacro", package: "BuildableMacro")
```

Or, if you are using Xcode, Click on "File > Add Packages" enter the following URL in the search box. 
then set the version to `from: 0.2.0`. 

```
https://github.com/Mr-Alirezaa/BuildableMacro.git
``` 

## Contributing

We warmly welcome contributions to the BuildableMacro project! Whether you're fixing bugs, improving the documentation, or adding new features, your help is appreciated. Here’s how you can contribute:

1. **Fork the Repository**: Start by forking the repository to your own GitHub account.
2. **Create a Branch**: Make your changes in a new branch.
3. **Make Your Changes**: Whether it's a new feature or a bug fix, your contributions make a difference.
4. **Write Tests**: Ensure your changes are working as expected.
5. **Submit a Pull Request**: Once you're satisfied, submit a pull request for review.

To give clarity of what is expected of our members, we have adopted the code of conduct defined by the Contributor Covenant. This document is used across many open source communities. For more, see the [Code of Conduct](CODE_OF_CONDUCT.md).

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](code_of_conduct.md)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
