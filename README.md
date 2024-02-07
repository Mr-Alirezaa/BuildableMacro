# BuildableMacro

BuildableMacro is a Swift package inspired by Apple's Observation framework, simplifying property modification in Swift through automated fluent setter function generation.

## Overview

BuildableMacro is a Swift package designed to enhance the way properties are modified and managed in Swift. Drawing inspiration from Apple's Observation framework, it introduces a set of macros that streamline the property modification process, making it more intuitive and fluent. The package's main feature is its ability to automatically generate setter functions for properties, following a pattern similar to SwiftUI's modifier approach.

This approach not only makes the code more readable but also maintains the familiarity for Swift developers accustomed to the SwiftUI framework. The package includes macros like `@Buildable`, `@BuildableTracked`, and `@BuildableIgnored`, each serving a specific purpose in the property modification workflow. `@BuildableTracked`, for example, creates fluent setter functions, which can be customized with names and parameters, whereas `@BuildableIgnored` excludes certain properties from this automated process, providing developers with control over their code structure and behavior.

## Features

- **@Buildable**: Automates the marking of settable properties as @BuildableTracked, excluding those marked as @BuildableIgnored.
- **@BuildableTracked**: Generates setter functions for each marked property, allowing fluent chaining of modifications.
- **@BuildableIgnored**: Excludes properties from automatic setter function generation.

## Usage

Apply the @Buildable macro to a type (class, struct, or actor) to automatically generate fluent setter functions for its properties. Customize the behavior using @BuildableTracked and @BuildableIgnored macros.

## Example

```swift
@Buildable
struct Sample {
    var p1: String
    // Other properties...
}

var sample = Sample(p1: "Initial")
sample = sample
    .p1("Updated")
```

## Installation

### Swift Package Manager

BuildableMacro is available through [Swift Package Manager](https://www.swift.org/package-manager/). To install
it, simply add the package to the dependencies of your Package.swift file:

```swift
dependencies: [
    .package(url: "https://github.com/Mr-Alirezaa/BuildableMacro.git", from: "0.1.0"),
]
```

Normally you'll want to depend on the `BuildableMacro` target:

```swift
.product(name: "BuildableMacro", package: "BuildableMacro")
```

Or, if you are using Xcode, Click on "File > Add Packages" enter the following URL in the search box. 
then set the version to `from: 0.1.0`. 

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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
