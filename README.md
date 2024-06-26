# Push Notification

<img src="https://raw.githubusercontent.com/surfstudio/flutter-open-source/main/assets/logo_black.png#gh-light-mode-only" width="200">
<img src="https://raw.githubusercontent.com/surfstudio/flutter-open-source/main/assets/logo_white.png#gh-dark-mode-only" width="200">

[![Build Status](https://shields.io/github/actions/workflow/status/surfstudio/flutter-push-notification/on_pull_request.yml?logo=github&logoColor=white)](https://github.com/surfstudio/flutter-push-notification)
[![Coverage Status](https://img.shields.io/codecov/c/github/surfstudio/flutter-push-notification?logo=codecov&logoColor=white)](https://app.codecov.io/gh/surfstudio/flutter-push-notification)
[![Pub Version](https://img.shields.io/pub/v/push_notification?logo=dart&logoColor=white)](https://pub.dev/packages/push_notification)
[![Pub Likes](https://badgen.net/pub/likes/push_notification)](https://pub.dev/packages/push_notification)
[![Pub popularity](https://badgen.net/pub/popularity/push_notification)](https://pub.dev/packages/push_notification/score)
![Flutter Platform](https://badgen.net/pub/flutter-platform/push_notification)

## Overview

Library for implementing push notifications.
The module contains the main work with push notifications.

## Example

An example of using the library can be found in [example](example).

* Create a notification data type through inheritance `NotificationPayload`.
* Create a strategy for handling notifications through inheritance `PushHandleStrategy`.
* Create a factory of strategies through inheritance `PushHandleStrategyFactory`.

* To receive notifications, you need to create an instance. `MessagingService`.
* To display notifications, you need to create an instance `NotificationController`.
* And pass created instances when creating `PushHandler` that will create the strategy using the factory.

## Installation

Add `push_notification` to your `pubspec.yaml` file:

```yaml
dependencies:
  push_notification: $currentVersion$
```

<p>At this moment, the current version of <code>push_notification</code> is <a href="https://pub.dev/packages/push_notification"><img style="vertical-align:middle;" src="https://img.shields.io/pub/v/push_notification.svg" alt="push_notification version"></a>.</p>

## Changelog

All notable changes to this project will be documented in [this file](./CHANGELOG.md).

## Issues

To report your issues, file directly in the [Issues](https://github.com/surfstudio/flutter-push-notification/issues) section.

## Contribute

If you would like to contribute to the package (e.g. by improving the documentation, fixing a bug or adding a cool new feature), please read our [contribution guide](./CONTRIBUTING.md) first and send us your pull request.

Your PRs are always welcome.

## How to reach us

Please feel free to ask any questions about this package. Join our community chat on Telegram. We speak English and Russian.

[![Telegram](https://img.shields.io/badge/chat-on%20Telegram-blue.svg)](https://t.me/SurfGear)

## License

[Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0)
