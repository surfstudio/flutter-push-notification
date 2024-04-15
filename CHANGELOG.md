# Changelog

## 2.0.1

* Rebranding.

## 2.0.0

* Fix bug with dependencies resolving on android
* update dependency constraints to sdk: '>=3.0.0 <4.0.0' flutter: '>=3.0.0'
* update minimum surf_lint_rules version to 3.0.0
* `_getStrategyBuilder` in `PushHandleStrategyFactory` now processes `messageData` the same on both ios and android
* `enum MessageHandlerType` has been updated to reflect the changed message handlers in FirebaseMessaging. `onLaunch` and `onResume` removed, `onBackgroundMessage` and `onMessageOpenedApp` added.
* fixed parsing error in the `internalOnSelectNotification` method in `NotificationController`
* `handleMessage` in `PushHandler` method has been updated to match the updated `MessageHandlerType`
* fixed the problem of incorrect display of push notifications on iOS
* updated usage example
* updated docs: no longer need to specify `click_action: FLUTTER_NOTIFICATION_CLICK` in notification and add `intent-filter` to android manifest


## 1.1.1

* v2 embedded support
* internal improvement

## 1.1.0

* Stable release

## 1.0.1-dev.1

* Update `rxdart` dependency to `0.27.0`.

## 1.0.0

* Migrated to null safety, min SDK is `2.12.0`.

## 0.0.1-dev.6

* now delegate implements in show instead of requestPermission

## 0.0.1-dev.3

* Fix lint hints

## 0.0.1-dev.0

* Initial release
