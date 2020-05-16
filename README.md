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
