# ``BuildableMacro``

BuildableMacro is a Swift package inspired by Apple's Observation framework, simplifying property modification in Swift through automated fluent setter function generation.

## Overview

BuildableMacro is a Swift package designed to enhance the way properties are modified and managed in Swift. Drawing inspiration from Apple's Observation framework, it introduces a set of macros that streamline the property modification process, making it more intuitive and fluent. The package's main feature is its ability to automatically generate setter functions for properties, following a pattern similar to SwiftUI's modifier approach.

This approach not only makes the code more readable but also maintains the familiarity for Swift developers accustomed to the SwiftUI framework. The package includes macros like [`@Buildable`](<doc:BuildableMacro/Buildable()>), [`@BuildableTracked`](<doc:BuildableMacro/BuildableTracked(name:forceEscaping:)>), and [`@BuildableIgnored`](<doc:BuildableMacro/BuildableIgnored()>), each serving a specific purpose in the property modification workflow. [`@BuildableTracked`](<doc:BuildableMacro/BuildableTracked(name:forceEscaping:)>), for example, creates fluent setter functions, which can be customized with names and parameters, whereas [`@BuildableIgnored`](<doc:BuildableMacro/BuildableIgnored()>) excludes certain properties from this automated process, providing developers with control over their code structure and behavior.

## Topics

- <doc:BuildableMacro/Buildable()>
- <doc:BuildableMacro/BuildableTracked(name:forceEscaping:)>
- <doc:BuildableMacro/BuildableIgnored()>
