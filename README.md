# CoEpi for iOS

This is the repository for the iOS implementation of CoEpi. See [CoEpi.org/vision](https://www.coepi.org/vision.html) for background, and see the rest of our CoEpi repositories [here](https://github.com/Co-Epi). 

## Build Status

Develop branch: [![Build status](https://build.appcenter.ms/v0.1/apps/d7359ba7-b4c3-4827-854f-a7c16628b2fe/branches/develop/badge)](https://appcenter.ms/users/scottleibrand/apps/CoEpi-iOS/build/branches/develop)

## Setup

- Install [Carthage](https://github.com/Carthage/Carthage)*
- in the root of your project, run
```ruby
carthage bootstrap
```
\* This project uses primarily SPM as dependecy manager. Carthage is used temporarily as [fallback for some dependencies](https://github.com/Co-Epi/app-ios/wiki/Architecture) 

- Install [swiftLint](https://github.com/realm/SwiftLint/releases)
- Brew install available
``` ruby
brew install swiftlint
```

## Core

The [core](https://github.com/Co-Epi/app-backend-rust) (domain logic, networking, etc.) of this app is written in Rust. It's used as a normal dependency, via Carthage, so you don't need additional setup.

If you want to contribute to core, create a PR in its [repo](https://github.com/Co-Epi/app-backend-rust). The documentation to set it up for iOS is in its [wiki](https://github.com/Co-Epi/app-backend-rust/wiki/Building-library-for-iOS).

## Contribute

CoEpi is an open source project with an MIT license - please do feel free to contribute improvements!

1. Some [code guidelines](https://github.com/Co-Epi/app-ios/wiki/Code-guidelines) and recommendations exist.
2. For new contributors, fork the `develop` branch to get started.
3. Commit changes to your version branch. 
4. Push your code, and make a pull request back to the CoEpi `develop` branch. 

Need help getting started? Just ask! You can [open an issue](https://github.com/Co-Epi/app-ios/issues/new/choose), or start your PR, and tag `@danamlewis` or `@scottleibrand` in a comment to ask for assistance.

### Internationalization

Any text visible to the user should be translated into the phone's preferred language.
See the [Internationalization wiki page](https://github.com/Co-Epi/app-ios/wiki/Internationalization) for details on how to do that.

### Autogeneration of Swift code (e.g. Equatable)

- Install [Sourcery](https://github.com/krzysztofzablocki/Sourcery#installation)
- Run `sourcery` in the project's root.

### Autoformat

This project uses [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) to format code. After installing it, you can format from the [terminal](https://github.com/nicklockwood/SwiftFormat#command-line-tool) or using an [Xcode extension](https://github.com/nicklockwood/SwiftFormat#xcode-source-editor-extension) (you can assign a shortcut to it). For now not integrated in the build process, as it [clears the undo history](https://github.com/nicklockwood/SwiftFormat#xcode-build-phase). 

## Test CoEpi on iOS

Looking to test CoEpi on iOS? You can run it locally, or [use the latest version available on TestFlight here](https://bit.ly/CoEpiTestFlightiOS).
