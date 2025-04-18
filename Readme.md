# NotificationTask

[![0 dependencies!](https://0dependencies.dev/0dependencies.svg)](https://0dependencies.dev)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsamsonjs%2FNotificationTask%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/samsonjs/NotificationTask)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsamsonjs%2FNotificationTask%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/samsonjs/NotificationTask)

## Overview

`NotificationTask` is

## Installation

The only way to install this package is with Swift Package Manager (SPM). Please [file a new issue][] or submit a pull-request if you want to use something else.

[file a new issue]: https://github.com/samsonjs/NotificationTask/issues/new

### Supported Platforms

This package is supported on iOS 16.0+ and macOS 12.0+.

### Xcode

When you're integrating this into an app with Xcode then go to your project's Package Dependencies and enter the URL `https://github.com/samsonjs/NotificationTask` and then go through the usual flow for adding packages.

### Swift Package Manager (SPM)

When you're integrating this using SPM on its own then add this to the list of dependencies your Package.swift file:

```swift
.package(url: "https://github.com/samsonjs/NotificationTask.git", .upToNextMajor(from: "0.1.0"))
```

and then add `"NotificationTask"` to the list of dependencies in your target as well.

## Usage

The simplest example uses a closure that receives the notification:

```swift
import NotificationTask

@MainActor class SimplestVersion {
    let task = NotificationTask(name: .NSCalendarDayChanged) { _ in
        print("The date is now \(Date.now)")
    }
}
```

Example using context to avoid reference cycles with `self`:

```swift
import NotificationTask

@MainActor class WithContext {
    var notificationTask: NotificationTask?

    init() {
        notificationTask = NotificationTask(name: .NSCalendarDayChanged, context: self) { _self, _ in
            _self.dayChanged()
        }
    }

    func dayChanged() {
        print("The date is now \(Date.now)")
    }
}
```

The closure is async so you can await in there if you need to.

## License

Copyright © 2025 [Sami Samhuri](https://samhuri.net) <sami@samhuri.net>. Released under the terms of the [MIT License][MIT].

[MIT]: https://sjs.mit-license.org
