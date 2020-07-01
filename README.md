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

1. Read the [code guidelines](https://github.com/Co-Epi/app-ios/wiki/Code-guidelines).

2. Create a branch
- If you belong to the organization:
Create a branch
- If you don't belong to the organization:
Fork and create a branch in the fork

3. Commit changes to the branch
4. Push your code and make a pull request

### Internationalization

Any text visible to the user should be translated into the phone's preferred language.
See the [Internationalization wiki page](https://github.com/Co-Epi/app-ios/wiki/Internationalization) for details on how to do that.
