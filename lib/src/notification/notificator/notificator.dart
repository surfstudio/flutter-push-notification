// Copyright (c) 2019-present,  SurfStudio LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:push_notification/src/notification/notificator/android/android_notification.dart';
import 'package:push_notification/src/notification/notificator/ios/ios_notification.dart';
import 'package:push_notification/src/notification/notificator/notification_specifics.dart';
import 'package:push_notification/src/util/platform_wrapper.dart';

/// Callback notification clicks.
///
/// [notificationData] - notification data.
typedef OnNotificationTapCallback = void Function(Map notificationData);

/// Callback on permission decline.
typedef OnPermissionDeclineCallback = void Function();

/// Channel name.
const String channelName = 'surf_notification';

/// Methods names.
const String callInit = 'initialize';
const String callShow = 'show';
const String callRequest = 'request';
const String openCallback = 'notificationOpen';
const String permissionDeclineCallback = 'permissionDecline';

/// Arguments names.
const String pushIdArg = 'pushId';
const String titleArg = 'title';
const String bodyArg = 'body';
const String imageUrlArg = 'imageUrl';
const String dataArg = 'data';
const String notificationSpecificsArg = 'notificationSpecifics';

/// Util for displaying notifications for Android and iOS.
class Notificator {
  static const _channel = MethodChannel(channelName);

  /// Callback notification clicks.
  final OnNotificationTapCallback onNotificationTapCallback;

  /// Callback notification decline(iOS only).
  final OnPermissionDeclineCallback? onPermissionDecline;

  IOSNotification? iosNotification;
  AndroidNotification? androidNotification;
  late PlatformWrapper _platform;

  Notificator({
    required this.onNotificationTapCallback,
    this.onPermissionDecline,
    PlatformWrapper? platform,
    this.iosNotification,
    this.androidNotification,
  }) {
    _platform = platform ?? PlatformWrapper();
    init();
  }

  /// Request notification permissions (iOS only).
  Future<bool?> requestPermissions({
    bool? requestSoundPermission,
    bool? requestAlertPermission,
  }) {
    return iosNotification!.requestPermissions(
      requestSoundPermission: requestSoundPermission,
      requestAlertPermission: requestAlertPermission,
    );
  }

  /// Show notification.
  ///
  /// [id] - notification identifier.
  /// [title] - title.
  /// [body] - the main text of the notification.
  /// [data] - data for notification.
  /// [notificationSpecifics] - notification specifics.
  Future show(
    int id,
    String title,
    String body, {
    String? imageUrl,
    Map<String, String>? data,
    NotificationSpecifics? notificationSpecifics,
  }) {
    if (_platform.getPlatform() == TargetPlatform.android) {
      return androidNotification!.show(
        id,
        title,
        body,
        imageUrl,
        data,
        notificationSpecifics?.androidNotificationSpecifics,
      );
    } else if (_platform.getPlatform() == TargetPlatform.iOS) {
      return iosNotification!.show(
        id,
        title,
        body,
        imageUrl,
        data,
        notificationSpecifics?.iosNotificationSpecifics,
      );
    }

    return Future<void>.value();
  }

  @visibleForTesting
  Future init() async {
    if (_platform.getPlatform() == TargetPlatform.android) {
      androidNotification ??= AndroidNotification(
        channel: _channel,
        onNotificationTap: onNotificationTapCallback,
      );

      return androidNotification!.init();
    } else if (_platform.getPlatform() == TargetPlatform.iOS) {
      iosNotification ??= IOSNotification(
        channel: _channel,
        onNotificationTap: onNotificationTapCallback,
        onPermissionDecline: onPermissionDecline,
      );

      return iosNotification!.init();
    }
  }
}
