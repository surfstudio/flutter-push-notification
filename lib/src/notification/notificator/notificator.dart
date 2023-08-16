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
typedef OnNotificationTapCallback = void Function(Map<dynamic, dynamic> notificationData);

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

  @visibleForTesting
  final PlatformWrapper platform;

  IOSNotification? iosNotification;
  AndroidNotification? androidNotification;

  Notificator({
    required this.onNotificationTapCallback,
    this.onPermissionDecline,
    this.iosNotification,
    this.androidNotification,
    PlatformWrapper? platform,
    MethodChannel? channel,
  }) : platform = platform ?? PlatformWrapper() {
    init(methodChannel: channel);
  }

  /// Request notification permissions (iOS only).
  Future<bool?> requestPermissions({
    bool? requestSoundPermission,
    bool? requestAlertPermission,
  }) {
    if (!platform.isIOS) {
      return Future.value(true);
    } else {
      return iosNotification!.requestPermissions(
        requestSoundPermission: requestSoundPermission,
        requestAlertPermission: requestAlertPermission,
      );
    }
  }

  /// Show notification.
  ///
  /// [id] - notification identifier.
  /// [title] - title.
  /// [body] - the main text of the notification.
  /// [data] - data for notification.
  /// [notificationSpecifics] - notification specifics.
  Future<dynamic> show(
    int id,
    String title,
    String body, {
    String? imageUrl,
    Map<String, String>? data,
    NotificationSpecifics? notificationSpecifics,
  }) {
    if (platform.isAndroid) {
      return androidNotification!.show(
        id,
        title,
        body,
        imageUrl,
        data,
        notificationSpecifics?.androidNotificationSpecifics,
      );
    } else if (platform.isIOS) {
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
  Future<dynamic> init({MethodChannel? methodChannel}) async {
    if (platform.isAndroid) {
      androidNotification ??= AndroidNotification(
        channel: methodChannel ?? _channel,
        onNotificationTap: onNotificationTapCallback,
      );

      return androidNotification!.init();
    } else if (platform.isIOS) {
      iosNotification ??= IOSNotification(
        channel: methodChannel ?? _channel,
        onNotificationTap: onNotificationTapCallback,
        onPermissionDecline: onPermissionDecline,
      );

      return iosNotification!.init();
    }
  }
}
